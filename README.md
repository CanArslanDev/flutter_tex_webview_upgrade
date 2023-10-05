# flutter_tex

[![Pub](https://img.shields.io/pub/v/flutter_tex.svg)](https://pub.dartlang.org/packages/flutter_tex)

`flutter_tex` is a Flutter package used to display content containing LaTeX and MathML in your Flutter applications. The package uses a webview to render LaTeX and MathML content.

## Update

This update includes an upgrade to a newer version of the `webview_flutter ` package. The changes made are as follows:

- The `webview_flutter ` package has been replaced with version [4.4.0](https://pub.dev/packages/webview).
- Benefits and fixes introduced by the update are documented.
- Dependencies in the `pubspec.yaml` file have been updated accordingly.

## Installation

To apply the update in your project, add the following lines to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_tex:
    git:
      url: https://github.com/CanArslanDev/flutter_tex_webview_upgrade
