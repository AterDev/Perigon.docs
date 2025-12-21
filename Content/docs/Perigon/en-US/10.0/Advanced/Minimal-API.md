# Minimal API

## Overview

The comparison that Minimal API performs better than MVC API is an objective fact, but there are also some misconceptions.

Performance differences are mainly in two aspects: one is the difference in default features, and the other is AOT support.

## Default Feature Differences

Minimal API does not enable some features by default, while MVC API enables them by default, such as:

- Complete model binding (IFormFile support) and validation (automatically return 400 errors)
- Filters
- Exception handling
- Resolution providers
- Others...

And many features are what we need. In MVC, you can also close some features through configuration to optimize some performance.

When using Minimal API, when you want to implement more complete functions, its performance and code composition will become closer and closer to MVC API.

Many performance comparison differences, under default configuration, Minimal API will naturally be faster, but obviously, the functional features they provide are not equal.

When you add more features to Minimal API and remove some default features for MVC API, it may be another result.

In summary, when the features are similar, the performance difference between Minimal API and MVC API can be almost ignored, but you need to do more work at the code level.

## AOT Support

The core issue is that Minimal API supports AOT compilation, while MVC API does not.

Currently, there is no exact information indicating whether and when Microsoft will support AOT compilation for WebAPI (MVC).

## Combined Use

Minimal API and MVC API can be used in combination, they are not mutually exclusive.

The main business process can be implemented using MVC API to keep the hierarchical structure clear and the development and maintenance standardized.

For some temporary test APIs or APIs with specific functions, Minimal API can be used to implement them.
