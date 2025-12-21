# Project Template Packaging

Execute the script `installPackage.ps1` to package and install the project template locally.

Regarding packaging behavior, there is a clear definition in the template project `Pack.csproj`, which excludes some unnecessary files and directories. The following details the content related to template project packaging.

## Project Configuration

The template project is in the `src/Template` directory and contains a `Pack.csproj` file, which is mainly used to configure the packaging content, such as:

```xml
 <PropertyGroup>
        <!-- Define common exclusion patterns -->
        <CommonExcludes>**\bin\**;**\obj\**;**\.vs\**</CommonExcludes>
        <NodeExcludes>**\node_modules\**;**\.angular\**;**\*.lock</NodeExcludes>
        <SpecialExcludes>templates\ApiStandard\src\Definition\EntityFramework\DBProvider\ModuleContextBase.cs</SpecialExcludes>
        <EntityExcludes>templates\ApiStandard\src\Definition\Entity\*\*</EntityExcludes>
    </PropertyGroup>
    <ItemGroup>
        <!-- Define exclusion pattern array -->
        <ExcludePatterns Include="$(CommonExcludes)" />
        <ExcludePatterns Include="$(NodeExcludes)" />
        <ExcludePatterns Include="$(SpecialExcludes)" />
        <ExcludePatterns Include="$(EntityExcludes)" />
        <ExcludePatterns Include="templates\**\src\Modules\**" />
        <ExcludePatterns Include="templates\**\.tmp\**" />
    </ItemGroup>

    <ItemGroup>
        <Content Include="templates\ApiStandard\**\*" Exclude="@(ExcludePatterns)" />
        <Content Include="templates\ApiStandard\src\Modules\CommonMod\**"
            Exclude="**\bin\**;**\obj\**" />
        <Content Include="templates\ApiStandard\src\Modules\SystemMod\**"
            Exclude="**\bin\**;**\obj\**" />
        <Content Include="templates\ApiStandard\src\Definition\Entity\SystemMod\**"/>
        <Compile Remove="**\*" />
    </ItemGroup>
```
Mainly excluded unnecessary directories and files such as **bin/obj/node_modules/.angular**, for module content, only `CommonMod` and `SystemMod` modules are retained as the default code content of the solution.

## Project Module Description

The template project contains multiple modules. Usually a module project includes:

- Models
- Managers
- Worker
- Controllers
- ModuleExtensions.cs

These modules also depend on:

- Entity
- EFCore DbContext

### Template Packaging Processing

The default template only retains CommonMod and SystemMod related content, others are not included, which requires:

- Remove other modules
- Remove entities corresponding to other modules
- Remove ModuleDbContext

### Module Content Packaging Processing

Modules have been removed from the template, but module content needs to be packaged separately into template.zip to support subsequent selection of modules to integrate.
Content to be packaged:

- Entity classes
- Module directory
  
The packaging script is `PackModules.ps1`. After execution, a `template.zip` file will be generated as a resource file for the tool.

### Frontend Packaging Processing

- Angular frontend project is packaged into the project template by default.
- Use dotnet template options to determine whether it is needed.
