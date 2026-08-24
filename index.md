---
layout: page
title: 算法语言Scheme修订<sup>6</sup>报告
title_plain: 算法语言Scheme修订⁶报告
tagline: R6RS简体中文翻译
permalink: /
r6rs_home: true
description: R6RS简体中文翻译的分章阅读目录
---

<div class="r6rs-home-intro">
  <p>规范正文已按大章拆分，便于阅读、定位和分享。原来的完整单页视图仍然保留。</p>
  <div class="r6rs-reading-options">
    <a href="{{ '/preface/' | relative_url }}">开始分章阅读</a>
    <a href="{{ '/single-page/' | relative_url }}">打开单页版</a>
  </div>
</div>

## 分章目录

<nav class="r6rs-chapter-grid" aria-label="R6RS分章目录">
{% for item in site.data.r6rs_pages %}
  <a href="{{ item.url | relative_url }}">{{ item.title }}</a>
{% endfor %}
</nav>

<script>
(function () {
  if (window.location.hash) {
    window.location.replace("{{ '/single-page/' | relative_url }}" + window.location.hash);
  }
}());
</script>
