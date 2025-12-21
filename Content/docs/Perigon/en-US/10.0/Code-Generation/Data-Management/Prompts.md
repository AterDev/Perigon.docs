# Prompts

Version V10 added MCP support. We hope to provide users with more customization capabilities and better leverage LLM's ability to generate more reliable code.

When customizing tools, we need to use prompts to guide the LLM to generate code.

## Viewing Prompts

In the `Data Management` page of **Studio**, click `Prompts` to view the prompts currently in the system.

You can also view prompt files in the `.github/prompts` directory in the project root directory. The page will read and display prompts from this directory.

> [!TIP]
> We reuse the **.github/prompts** directory for better integration with some tools.

## Prompt Management

Like templates, you can create prompt categories (corresponding to directory names), then add prompt files in that category.

You can add through the `UI` page or directly add directories or files in the `.github/prompts` directory.

> Note: Prompt files need to have a `prompt.md` suffix. When adding using Studio, the suffix will be added automatically.

## Prompt Examples

