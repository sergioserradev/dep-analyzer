
i want to write a dart cli app that analyzes dependencies in a flutter project.
The tool should read a yaml config file like:

```yaml
groups:
  - name: features
    - feature_a
    - feature_b
  - name: core
    - core_a
    - core_b
```

The tool should then analyze each package in the project and 
find invalid dependencies and circular dependencies. Dependencies inside groups can have 
dependencies; only within their own group.
