# Minimal API

## Overview

It’s often stated that Minimal API outperforms MVC API, which is generally true—but context matters.

The performance gap mostly comes from two areas: differences in default features and AOT support.

## Default Features

Minimal API disables several features by default that MVC enables, such as:

- Full model binding (including `IFormFile`) and automatic validation (automatic 400 responses)
- Filters
- Exception handling
- Various resolvers/providers
- And more…

Many of these features are useful in real projects. You can also disable some of them in MVC to gain performance. As you add more completeness to Minimal API, its performance and structure start to resemble MVC.

So benchmarks with default settings naturally favor Minimal API, but the capabilities aren’t equivalent. If you add features to Minimal API and trim defaults in MVC, results can flip.

In short, when feature parity is the goal, the performance difference is usually negligible—though you’ll likely do more manual wiring with Minimal API.

## AOT Support

Minimal API supports AOT compilation; MVC API currently does not. There’s no definitive timeline for AOT support in MVC Web API.

## Use Both Together

Minimal API and MVC API aren’t mutually exclusive. Use MVC for primary business flows to keep layers and conventions clear. Use Minimal API for temporary endpoints or highly targeted scenarios.
