# Prompts

Version 10.0 added MCP support. We aim to provide users with greater customization capabilities and better leverage LLM's ability to generate reliable code.

When customizing tools, prompts are used to guide the LLM in generating code.

## Viewing Prompts

In the `Data Management` page of **Studio**, click `Prompts` to view the prompts currently in the system.

You can also view prompt files in the `.github/prompts` directory in the project root directory. The page will read and display prompts from this directory.

> [!TIP]
> We reuse the **.github/prompts** directory for better integration with some tools.

## Prompt Management

Like templates, you can create prompt categories (corresponding to directory names), then add prompt files within those categories.

You can add prompts through the `UI` page or directly add directories or files in the `.github/prompts` directory.

> Note: Prompt files require a `prompt.md` suffix. When adding via Studio, the suffix is added automatically.

## Prompt Examples

