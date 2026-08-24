#!/usr/bin/env node

// Dependency-free browser layout check using Chrome's DevTools protocol.
// It reads an already-served Jekyll build and writes optional screenshots.

import { spawn } from "node:child_process";
import { promises as fs } from "node:fs";
import os from "node:os";
import path from "node:path";

function argument(name, fallback) {
  const position = process.argv.indexOf(name);
  return position >= 0 && position + 1 < process.argv.length
    ? process.argv[position + 1]
    : fallback;
}

const baseUrl = argument("--base-url", "http://127.0.0.1:4000").replace(/\/$/, "");
const outputDirectory = path.resolve(
  argument("--output-dir", path.join(os.tmpdir(), "r6rs-browser-check"))
);
const chromePath = argument(
  "--chrome",
  process.platform === "win32"
    ? "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"
    : "google-chrome"
);
const selectedCase = argument("--case", null);

const delay = (milliseconds) =>
  new Promise((resolve) => setTimeout(resolve, milliseconds));

async function waitForDevTools(profileDirectory) {
  const activePortPath = path.join(profileDirectory, "DevToolsActivePort");
  for (let attempt = 0; attempt < 120; attempt += 1) {
    try {
      const lines = (await fs.readFile(activePortPath, "utf8")).trim().split(/\r?\n/);
      if (lines.length >= 2) {
        return {
          port: Number(lines[0]),
          browserSocketUrl: `ws://127.0.0.1:${lines[0]}${lines[1]}`,
        };
      }
    } catch {
      // Chrome has not written the port file yet.
    }
    await delay(100);
  }
  throw new Error("Chrome did not expose a DevTools port.");
}

async function waitForPageSocket(port) {
  for (let attempt = 0; attempt < 100; attempt += 1) {
    const response = await fetch(`http://127.0.0.1:${port}/json/list`);
    const targets = await response.json();
    const page = targets.find((target) => target.type === "page");
    if (page?.webSocketDebuggerUrl) {
      return page.webSocketDebuggerUrl;
    }
    await delay(100);
  }
  throw new Error("Chrome did not create a page target.");
}

class DevToolsClient {
  constructor(socketUrl) {
    this.nextIdentifier = 1;
    this.pending = new Map();
    this.events = [];
    this.socket = new WebSocket(socketUrl);
    this.opened = new Promise((resolve, reject) => {
      this.socket.addEventListener("open", resolve, { once: true });
      this.socket.addEventListener("error", reject, { once: true });
    });
    this.socket.addEventListener("message", (event) => {
      const message = JSON.parse(event.data);
      if (!message.id) {
        if (message.method === "Runtime.exceptionThrown" ||
            message.method === "Log.entryAdded") {
          this.events.push({ method: message.method, params: message.params });
          this.events = this.events.slice(-20);
        }
        return;
      }
      if (!this.pending.has(message.id)) {
        return;
      }
      const { resolve, reject } = this.pending.get(message.id);
      this.pending.delete(message.id);
      if (message.error) {
        reject(new Error(`${message.error.message} (${message.error.code})`));
      } else {
        resolve(message.result);
      }
    });
  }

  async send(method, params = {}) {
    await this.opened;
    const id = this.nextIdentifier;
    this.nextIdentifier += 1;
    const response = new Promise((resolve, reject) => {
      this.pending.set(id, { resolve, reject });
    });
    this.socket.send(JSON.stringify({ id, method, params }));
    return response;
  }

  close() {
    this.socket.close();
  }
}

async function evaluate(client, expression) {
  const response = await client.send("Runtime.evaluate", {
    expression,
    returnByValue: true,
    awaitPromise: true,
  });
  if (response.exceptionDetails) {
    throw new Error(response.exceptionDetails.text || "Browser evaluation failed.");
  }
  return response.result.value;
}

async function waitForExpression(client, expression, timeoutMilliseconds = 15000) {
  const deadline = Date.now() + timeoutMilliseconds;
  while (Date.now() < deadline) {
    try {
      if (await evaluate(client, expression)) {
        return;
      }
    } catch {
      // Navigation can briefly destroy the JavaScript execution context.
    }
    await delay(150);
  }
  throw new Error(`Browser condition timed out: ${expression}`);
}

const metricsExpression = `(() => {
  const style = (element) => element ? getComputedStyle(element) : null;
  const preCode = document.querySelector("pre code");
  const inlineCode = [...document.querySelectorAll("code")].find(
    (element) => !element.closest("pre")
  );
  const rougeError = document.querySelector(".highlight .err");
  const activeChapter = document.querySelectorAll(".r6rs-chapter-list a.active");
  const title = document.querySelector(".page-header h1");
  const tagline = title?.querySelector("small");
  const viewportWidth = document.documentElement.clientWidth;
  const elementMetrics = [...document.body.querySelectorAll("*")]
    .map((element) => {
      const rectangle = element.getBoundingClientRect();
      const computed = style(element);
      return {
        tag: element.tagName.toLowerCase(),
        id: element.id,
        className: typeof element.className === "string" ? element.className : "",
        left: Math.round(rectangle.left),
        right: Math.round(rectangle.right),
        width: Math.round(rectangle.width),
        clientWidth: element.clientWidth,
        scrollWidth: element.scrollWidth,
        overflowX: computed?.overflowX ?? null,
        whiteSpace: computed?.whiteSpace ?? null,
        containedByOverflow: (() => {
          for (let ancestor = element.parentElement;
               ancestor && ancestor !== document.body;
               ancestor = ancestor.parentElement) {
            const ancestorStyle = style(ancestor);
            const ancestorRectangle = ancestor.getBoundingClientRect();
            if (["auto", "hidden", "scroll", "clip"].includes(ancestorStyle.overflowX) &&
                ancestorRectangle.right <= viewportWidth + 1) {
              return true;
            }
          }
          return false;
        })(),
        text: (element.textContent || "").trim().slice(0, 80),
      };
    });
  const overflowingElements = elementMetrics
    .filter((item) => item.right > viewportWidth + 1 || item.left < -1)
    .sort((left, right) => right.right - left.right)
    .slice(0, 12);
  const uncontainedOverflowingElements = elementMetrics
    .filter((item) =>
      !item.containedByOverflow &&
      (item.right > viewportWidth + 1 || item.left < -1)
    )
    .sort((left, right) => right.right - left.right)
    .slice(0, 12);
  return {
    innerWidth: window.innerWidth,
    clientWidth: document.documentElement.clientWidth,
    visualViewportWidth: window.visualViewport?.width ?? null,
    screenWidth: window.screen.width,
    devicePixelRatio: window.devicePixelRatio,
    viewportMeta: document.querySelector('meta[name="viewport"]')?.content ?? null,
    documentWidth: document.documentElement.scrollWidth,
    bodyWidth: document.body.scrollWidth,
    bodyClass: document.body.className,
    preCodeWhiteSpace: style(preCode)?.whiteSpace ?? null,
    inlineCodeWhiteSpace: style(inlineCode)?.whiteSpace ?? null,
    rougeErrorBorderWidth: style(rougeError)?.borderTopWidth ?? null,
    sidebarPosition: style(document.querySelector(".r6rs-sidebar"))?.position ?? null,
    activeChapterCount: activeChapter.length,
    mathCount: document.querySelectorAll(".MathJax").length,
    mathPreviewCount: document.querySelectorAll(".MathJax_Preview").length,
    visibleMathPreviewCount: [...document.querySelectorAll(".MathJax_Preview")]
      .filter((element) => getComputedStyle(element).display !== "none").length,
    mathPreviewOverflowX:
      style(document.querySelector(".MathJax_Preview"))?.overflowX ?? null,
    titleFontSize: style(title)?.fontSize ?? null,
    taglineDisplay: style(tagline)?.display ?? null,
    overflowingElements,
    uncontainedOverflowingElements,
  };
})()`;

async function inspectPage(client, testCase) {
  const deviceMetrics = {
    width: testCase.width,
    height: testCase.height,
    screenWidth: testCase.width,
    screenHeight: testCase.height,
    deviceScaleFactor: 1,
    mobile: testCase.mobile,
  };
  await client.send("Emulation.clearDeviceMetricsOverride");
  await client.send("Emulation.setDeviceMetricsOverride", deviceMetrics);
  const url = baseUrl + testCase.path;
  await client.send("Page.navigate", { url });
  await waitForExpression(
    client,
    `document.readyState === "complete" && location.href.startsWith(${JSON.stringify(url)})`
  );
  // Reapply after navigation because switching between desktop and mobile
  // emulation can otherwise retain the previous page's layout viewport.
  await client.send("Emulation.setDeviceMetricsOverride", deviceMetrics);

  if (testCase.mathState === "preview") {
    await waitForExpression(
      client,
      "Boolean(window.MathJax && document.querySelector('.MathJax_Preview, .MathJax'))",
      25000
    );
  }
  if (testCase.mathState === "final") {
    try {
      await waitForExpression(
        client,
        `Boolean(
            window.MathJax &&
            document.querySelector(".MathJax") &&
            !document.querySelector(".MathJax_Processing") &&
            [...document.querySelectorAll(".MathJax_Preview")].every(
              (element) => getComputedStyle(element).display === "none"
            )
          )`,
        25000
      );
    } catch (error) {
      const diagnostics = await evaluate(client, `(() => ({
        mathJaxType: typeof window.MathJax,
        outputJax: window.MathJax ? Object.keys(MathJax.OutputJax || {}) : [],
        queuePending: window.MathJax?.Hub?.queue?.pending ?? null,
        queueRunning: window.MathJax?.Hub?.queue?.running ?? null,
        ajaxLoading: window.MathJax ? Object.keys(MathJax.Ajax.loading || {}) : [],
        previewCount: document.querySelectorAll(".MathJax_Preview").length,
        visiblePreviewCount: [...document.querySelectorAll(".MathJax_Preview")]
          .filter((element) => getComputedStyle(element).display !== "none").length,
        mathCount: document.querySelectorAll(".MathJax").length,
        processingCount: document.querySelectorAll(".MathJax_Processing").length,
        previewOuterHtml: document.querySelector(".MathJax_Preview")?.outerHTML.slice(0, 500) ?? null,
        previewParentHtml: document.querySelector(".MathJax_Preview")?.parentElement?.outerHTML.slice(0, 1200) ?? null,
        mathOuterHtml: document.querySelector(".MathJax")?.outerHTML.slice(0, 500) ?? null,
        scriptStates: [...document.querySelectorAll('script[type^="math/tex"]')]
          .slice(0, 8)
          .map((script) => script.MathJax?.state ?? null),
      }))()`);
      throw new Error(
        `${error.message}; diagnostics=${JSON.stringify(diagnostics)}; ` +
        `events=${JSON.stringify(client.events)}`
      );
    }
  }
  await delay(250);

  const metrics = await evaluate(client, metricsExpression);
  if (metrics.clientWidth !== testCase.width) {
    throw new Error(
      `${testCase.name}: expected viewport ${testCase.width}; ${JSON.stringify(metrics)}`
    );
  }
  if (metrics.documentWidth > metrics.clientWidth + 1 ||
      metrics.bodyWidth > metrics.clientWidth + 1) {
    if (metrics.uncontainedOverflowingElements.length > 0) {
      throw new Error(
        `${testCase.name}: horizontal overflow; ${JSON.stringify(metrics)}`
      );
    }
  }
  testCase.assert(metrics);

  const screenshot = await client.send("Page.captureScreenshot", {
    format: "png",
    fromSurface: true,
    captureBeyondViewport: false,
  });
  await fs.writeFile(
    path.join(outputDirectory, `${testCase.name}.png`),
    Buffer.from(screenshot.data, "base64")
  );
  return metrics;
}

const testCases = [
  {
    name: "home-mobile",
    path: "/",
    width: 320,
    height: 1000,
    mobile: true,
    mathState: null,
    assert(metrics) {
      if (metrics.bodyClass !== "r6rs-home-page" ||
          metrics.taglineDisplay !== "block" ||
          Number.parseFloat(metrics.titleFontSize) > 30.1) {
        throw new Error(`home-mobile: unexpected title layout ${JSON.stringify(metrics)}`);
      }
    },
  },
  {
    name: "chapter-11-desktop",
    path: "/chapters/11/",
    width: 1440,
    height: 1200,
    mobile: false,
    mathState: null,
    assert(metrics) {
      if (metrics.bodyClass !== "r6rs-page" ||
          metrics.inlineCodeWhiteSpace !== "normal" ||
          metrics.rougeErrorBorderWidth !== "0px" ||
          metrics.sidebarPosition !== "sticky" ||
          metrics.activeChapterCount !== 1) {
        throw new Error(`chapter-11-desktop: unexpected styles ${JSON.stringify(metrics)}`);
      }
    },
  },
  {
    name: "appendix-a-mobile",
    path: "/appendices/a/",
    width: 320,
    height: 1100,
    mobile: true,
    mathState: "preview",
    assert(metrics) {
      if (metrics.bodyClass !== "r6rs-page" ||
          metrics.inlineCodeWhiteSpace !== "normal" ||
          metrics.mathPreviewCount < 1 ||
          metrics.mathPreviewOverflowX !== "auto" ||
          metrics.sidebarPosition !== "static") {
        throw new Error(`appendix-a-mobile: unexpected styles ${JSON.stringify(metrics)}`);
      }
    },
  },
  {
    name: "chapter-04-math",
    path: "/chapters/04/",
    width: 1024,
    height: 1000,
    mobile: false,
    mathState: "final",
    assert(metrics) {
      if (metrics.bodyClass !== "r6rs-page" ||
          metrics.mathCount < 1 ||
          metrics.visibleMathPreviewCount !== 0) {
        throw new Error(`chapter-04-math: MathJax did not finish ${JSON.stringify(metrics)}`);
      }
    },
  },
];

await fs.mkdir(outputDirectory, { recursive: true });
const profileDirectory = await fs.mkdtemp(path.join(os.tmpdir(), "r6rs-chrome-"));
const chrome = spawn(
  chromePath,
  [
    "--headless=new",
    "--disable-gpu",
    "--hide-scrollbars",
    "--no-first-run",
    "--no-default-browser-check",
    "--remote-debugging-port=0",
    `--user-data-dir=${profileDirectory}`,
    "about:blank",
  ],
  { stdio: "ignore" }
);

let client;
try {
  const { port } = await waitForDevTools(profileDirectory);
  client = new DevToolsClient(await waitForPageSocket(port));
  await client.send("Page.enable");
  await client.send("Runtime.enable");
  await client.send("Log.enable");

  const results = [];
  // Keep mobile cases together; Chromium's headless viewport can retain a
  // desktop layout width when toggled back to mobile in the same target.
  const orderedTestCases = [...testCases]
    .filter((testCase) => !selectedCase || testCase.name === selectedCase)
    .sort((left, right) => Number(right.mobile) - Number(left.mobile));
  if (orderedTestCases.length === 0) {
    throw new Error(`Unknown browser test case: ${selectedCase}`);
  }
  for (const testCase of orderedTestCases) {
    results.push({
      name: testCase.name,
      metrics: await inspectPage(client, testCase),
    });
  }
  console.log(JSON.stringify(results, null, 2));
  console.log(`Browser layout verification passed; screenshots: ${outputDirectory}`);
} finally {
  client?.close();
  chrome.kill();
  const resolvedTemporaryRoot = path.resolve(os.tmpdir()) + path.sep;
  const resolvedProfile = path.resolve(profileDirectory);
  if (resolvedProfile.startsWith(resolvedTemporaryRoot)) {
    await fs.rm(resolvedProfile, { recursive: true, force: true, maxRetries: 5 });
  }
}
