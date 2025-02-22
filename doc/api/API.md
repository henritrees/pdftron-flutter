# PDFTron Flutter API

- [Utility Functions](#Utility-Functions)
- [Viewer Functions](#Viewer-Functions)
- [Events](#Events)
- [Viewer Configurations](#Viewer-Configurations)

## Utility Functions
This section is for some static methods for global library initialization, configuration, and utility. They could only be callable as a plugin. Below is an example for [`initialize`](#initialize):

```dart
PdftronFlutter.initialize('your_license_key');
```
### version

Obtains PDFTron SDK version.

```dart
String version = PdftronFlutter.version;
print('Current PDFTron SDK version is: ' + version);
```

### platformVersion

Obtains the current platform version.

```dart
String platformVersion = PdftronFlutter.platformVersion;
print('App is currently running on: ' + platformVersion);
```

### initialize

Initializes PDFTron SDK with your PDFTron commercial license key. You can run PDFTron in demo mode by not passing in a string, or by passing an empty string.

Parameters:

Name | Type | Required | Description
--- | --- | --- | ---
key | String | true | your PDFTron license key

Returns a Future.

Demo mode: 
```dart
PdftronFlutter.initialize();
```

Using commercial license key:
```dart
PdftronFlutter.initialize('your_license_key');
```

### exportAsImageFromFilePath
Export a PDF page to an image format defined in [`ExportFormat`](./lib/constants.dart). The page is taken from the PDF at the given filepath.

Parameters:

Name | Type | Description
--- | --- | ---
pageNumber | int | the page to be converted
dpi | double | the output image resolution
exportFormat | String | one of [`ExportFormat`](./lib/constants.dart) constants
filePath | String | local file path to pdf

Returns a Future.

Name | Type | Description
--- | --- | ---
resultImagePath | String | the temp path of the created image, user is responsible for clean up the cache

```dart
var resultImagePath = await PdftronFlutter.exportAsImageFromFilePath(1, 92, ExportFormat.BMP, "/sdcard/Download/red.pdf");
```

### setRequestedOrientation

Changes the orientation of this activity. Android only. 

For more information on the native API, see the [Android API reference](https://developer.android.com/reference/android/app/Activity#setRequestedOrientation(int)).

Parameters:

Name | Type | Required | Description
--- | --- | --- | ---
requestedOrientation | int | true | A [PTOrientation](./lib/constants.dart) constant.

Returns a Future.

```dart
PdftronFlutter.setRequestedOrientation(0);
```

## Viewer Functions
This section is for viewer related non-static methods. They would be callable in both plugin and widget versions. For example, [`openDocument`](#openDocument) is accessible in 2 ways:

Plugin:
```dart
void showViewer() async {
  await PdftronFlutter.openDocument('https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_about.pdf');
}
```

Widget (DocumentViewController):
```dart
void _onDocumentViewCreated(DocumentViewController controller) async {
  await controller.openDocument('https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_about.pdf');
}
```

You must choose either the widget or plugin, and use it for all APIs. Mixing widget and plugin APIs will not function correctly. For more information, see [Widget or Plugin](https://github.com/PDFTron/pdftron-flutter/blob/publish-prep/README.md#widget-or-plugin).

There are several custom classes used in these APIs: Annot, AnnotWithRect, Field, Rect, AnnotFlag, AnnotWithFlag and CustomToolbar. These classes are listed [here](/lib/options.dart), and the constants that are used in the examples below are all listed [here](/lib/constants.dart).

### Document

#### openDocument
Opens a document in the viewer with configurations.

Parameters:

Name | Type | Required | Description
--- | --- | --- | ---
document | String | true | path to the document
password | String? | false | password to an encrypted document
config | Config? | false | viewer configuration options

Returns a Future that would resolve when document is loaded.

For details regarding the config, please see this [section](#viewer-configurations).

Example:
```dart
var disabledElements = [Buttons.shareButton, Buttons.searchButton];
var disabledTools = [Tools.annotationCreateLine, Tools.annotationCreateRectangle];
var hideDefaultAnnotationToolbars = [DefaultToolbars.annotate, DefaultToolbars.draw];

var config = Config();
config.disabledElements = disabledElements;
config.disabledTools = disabledTools;
config.multiTabEnabled = false;
config.customHeaders = {'headerName': 'headerValue'};
config.hideDefaultAnnotationToolbars = hideDefaultAnnotationToolbars;
config.hideAnnotationToolbarSwitcher = true;
config.continuousAnnotationEditing = true;

var password = 'pdf_password';
await PdftronFlutter.openDocument(_document, password: password, config: config);
```

#### saveDocument
Saves the currently opened document in the viewer and gets the absolute path to the document. Must only be called when the document is opened in the viewer.

Returns a Future.

Future Parameters:

Name | Type | Description
--- | --- | ---
path | String? | the location of the saved document

```dart
var path = await PdftronFlutter.saveDocument();
```

#### getDocumentPath
Returns the path of the current document.

Returns a Future.

Future Parameters:

Name | Type | Description
--- | ---| ---
path | String? | the document path

```dart
var path = await PdftronFlutter.getDocumentPath();
```

#### openAnnotationList
Displays the annotation tab of the existing list container. If this tab has been disabled, the method does nothing.

Returns a Future that resolves when the view has loaded.

```dart
await PdftronFlutter.openAnnotationList();
```

#### openBookmarkList
Displays the bookmark tab of the existing list container. If this tab has been disabled, the method does nothing.

Returns a Future that resolves when the view has loaded.

```dart
await PdftronFlutter.openBookmarkList();
```

#### openOutlineList
Displays the outline tab of the existing list container. If this tab has been disabled, the method does nothing.

Returns a Future that resolves when the view has loaded.

```dart
await PdftronFlutter.openOutlineList();
```

#### openLayersList
On Android it displays the layers dialog while on iOS it displays the layers tab of the existing list container. If this tab has been disabled or there are no layers in the document, the method does nothing.

Returns a Future that resolves when the view has loaded.

```dart
await PdftronFlutter.openLayersList();
```

#### openThumbnailsView
Display a page thumbnails view.

This view allows users to navigate pages of a document. If [`thumbnailViewEditingEnabled`](#thumbnailViewEditingEnabled) is true, the user can also manipulate the document, including add, remove, re-arrange, rotate and duplicate pages.

Returns a Future.

```dart
await PdftronFlutter.openThumbnailsView();
```

#### openRotateDialog
Displays a rotate dialog. Android only.

The dialog allows users to rotate pages of the opened document by 90, 180 and 270 degrees. It also displays a thumbnail of the current page at the selected rotation angle.

Returns a Future.

```dart
await PdftronFlutter.openRotateDialog();
```

#### openAddPagesView
Displays the add pages view.

Requires a source rect in screen co-ordinates. On iOS this rect will be the anchor point for the view. The rect is ignored on Android.

Returns a Future.

Parameters:

Name | Type | Description
--- | --- | ---
rect | map | The rectangular area in screen co-ordinates with keys x1 (left), y1(bottom), y1(right), y2(top). Coordinates are in double format.

```dart
await PdftronFlutter.openAddPagesView({'x1': 10.0, 'y1': 10.0, 'x2': 20.0, 'y2': 20.0});
```

#### openViewSettings
Displays the view settings.

Requires a source rect in screen co-ordinates. On iOS this rect will be the anchor point for the view. The rect is ignored on Android.

Returns a Future.

Parameters:

Name | Type | Description
--- | --- | ---
rect | map | The rectangular area in screen co-ordinates with keys x1 (left), y1(bottom), y1(right), y2(top). Coordinates are in double format.

```dart
PdftronFlutter.openViewSettings({'x1': 10.0, 'y1': 10.0, 'x2': 20.0, 'y2': 20.0});
```

#### openCrop
Displays the page crop options dialog.

On iOS, this has no effect if [`hideTopToolbars`](#hideTopToolbars) is false.

Returns a Future.

```dart
PdftronFlutter.openCrop();
```

#### openManualCrop
Displays the manual page crop dialog.

Returns a Future.

```dart
PdftronFlutter.openManualCrop();
```

#### openSearch
Displays a search bar that allows the user to enter and search text within a document.

Returns a Future.

```dart
PdftronFlutter.openSearch();
```

#### openNavigationLists
Displays the existing list container. Its current tab will be the one last opened. 

Returns a Future that resolves when the view has loaded.

```dart
await PdftronFlutter.openNavigationLists();
```

### Viewer UI Configuration

#### setLeadingNavButtonIcon
Sets the file name of the icon to be used for the leading navigation button. The button will use the specified icon if [`showLeadingNavButton`](#showLeadingNavButton) (which by default is true) is true in the config.

Parameters:

Name | Type | Description
--- | ---| ---
leadingNavButtonIcon | String | the icon path to the navigation button

Returns a Future.

```dart
PdftronFlutter.setLeadingNavButtonIcon(Platform.isIOS ? 'ic_close_black_24px.png' : 'ic_arrow_back_white_24dp');
```

**Note**: to add the image file to your application, please follow the steps below:

##### Android
1. Add the image resource to the [`example/android/app/src/main/res/drawable`](/example/android/app/src/main/res/drawable) directory. For details about supported file types and potential compression, check out [here](https://developer.android.com/guide/topics/graphics/drawables#drawables-from-images).

<img alt='demo-android' src='https://pdftron.s3.amazonaws.com/custom/websitefiles/flutter/android_add_resources.png'/>

2. Now you can use the image in the viewer. For example, if you add `button_close.png` to drawable, you could use `'button_close'` in leadingNavButtonIcon.

##### iOS
1. After pods has been installed, open the .xcworkspace file for this application in Xcode (in this case, it's [`Runner.xcworkspace`](/example/ios/Runner.xcworkspace)), and navigate through the list below. This would allow you to add resources, in this case, an image, to your project.
- "Project navigator"
- "Runner" (or the app name)
- "Build Phases"
- "Copy Bundle Resources"
- "+".

<img alt='demo-ios' src='https://pdftron.s3.amazonaws.com/custom/websitefiles/flutter/ios_add_resources.png'/>

2. Now you can use the image in the viewer. For example, if you add `button_open.png` to the bundle, you could use `'button_open.png'` in leadingNavButtonIcon.

#### rememberLastUsedTool
boolean, optional, defaults to true, Android only

Defines whether the last tool used in the current viewer session will be the tool selected upon starting a new viewer session.

Example:

```dart
config.rememberLastUsedTool = false;
```

### Annotation Tools

#### setToolMode
Sets the current tool mode.

Parameters:

Name | Type | Description
--- | --- | ---
toolMode | String | One of [`Tools`](/lib/constants.dart) string constants, representing the tool mode to set

Returns a Future.

```dart
 PdftronFlutter.setToolMode(Tools.annotationCreateEllipse);
```

#### commitTool
Commits the current tool. Only available for multi-stroke ink and poly-shape.

Returns a Future.

Future Parameters:

Name | Type | Description
--- | --- | ---
committed | bool? | true if either ink or poly-shape tool is committed, false otherwise

```dart
var committed = await PdftronFlutter.commitTool();
print("Tool committed: $committed");
```

### Page

#### setCurrentPage

Sets current page of the document. Page numbers are 1-indexed.

Parameters:

Name | Type | Description
--- | --- | ---
pageNumber | int | the page number to be set as the current page; 1-indexed

Returns a Future.

Future Parameters:

Name | Type | Description
-- | -- | --
success | bool? | whether the setting process is successful.

```dart
var setResult = await controller.setCurrentPage(5);
print('Page set ' + (setResult ? 'successfully' : 'unsuccessfully'));
```

#### getCurrentPage

Gets current page of the document. Page numbers are 1-indexed.

Returns a Future.

Future Parameters:

Name | Type | Description
-- | -- | --
currentPage | int | the current page of the current document

```dart
var currentPage = await PdftronFlutter.getCurrentPage();
print("The current page is $currentPage");
```

#### getPageCount
Gets the total number of pages in the currently displayed document.

Returns a Future.

Future Parameters:

Name | Type | Description
--- | --- | ---
pageCount | int? | the page count of the current document

```dart
var pageCount = await PdftronFlutter.getPageCount();
print("The current doc has $pageCount pages");
```

#### getPageCropBox
Gets a map object of the crop box for the specified page.

Parameters:

Name | Type | Description
--- | --- | ---
pageNumber | int | the page number for the target crop box. It is 1-indexed

Returns a Future.

Future Parameters:

Name | Type | Description
--- | --- | ---
cropBox | [`Rect`](/lib/options.dart) | the crop box information map. It contains information for position (bottom-left: `x1`, `y1`; top-right: `x2`, `y2`) and size (`width`, `height`)

```dart
var cropBox = await PdftronFlutter.getPageCropBox(1);
print('The width of crop box for page 1 is: ' + cropBox.width.toString());
```

#### getPageRotation
Gets the rotation value of the specified page in the current document.

Parameters:

Name | Type | Description
--- | --- | ---
pageNumber | int | the page number for the target page. It is 1-indexed

Returns a Future.

Future Parameters:

Name | Type | Description
--- | --- | ---
pageRotation | int | the rotation degree of the page, one of 0, 90, 180 or 270 (clockwise).

```dart
var pageRotation = await PdftronFlutter.getPageRotation(1);
print("The rotation value of page 1 is $pageRotation");
```

#### rotateClockwise
Rotates all pages in the current document in clockwise direction (by 90 degrees).

Returns a Promise.

```dart
await PdftronFlutter.rotateClockwise();
```

#### rotateCounterClockwise
Rotates all pages in the current document in counter-clockwise direction (by 90 degrees).

Returns a Promise.

```dart
await PdftronFlutter.rotateCounterClockwise();
```

#### gotoPreviousPage
Go to the previous page of the document. If on first page, it will stay on first page.

Returns a Future.

Future Parameters:

Name | Type | Description
--- | --- | ---
pageChanged | bool | whether the setting process was successful (no change due to staying in first page counts as being successful)

```dart
var pageChanged = await PdftronFlutter.gotoPreviousPage();
if (pageChanged) {
  print("Successfully went to previous page");
}
```

#### gotoNextPage
Go to the next page of the document. If on last page, it will stay on last page.

Returns a Future.

Future Parameters:

Name | Type | Description
--- | --- | ---
pageChanged | bool | whether the setting process was successful (no change due to staying in last page counts as being successful)

```dart
var pageChanged = await PdftronFlutter.gotoNextPage();
if (pageChanged) {
  print("Successfully went to next page");
}
```

#### gotoFirstPage
Go to the first page of the document.

Returns a Future.

Future Parameters:

Name | Type | Description
--- | --- | ---
pageChanged | bool | whether the setting process was successful

```dart
var pageChanged = await PdftronFlutter.gotoFirstPage();
if (pageChanged) {
  print("Successfully went to first page");
}
```

#### gotoLastPage
Go to the last page of the document.

Returns a Future.

Future Parameters:

Name | Type | Description
--- | --- | ---
success | bool | whether the setting process was successful

```dart
var pageChanged = await PdftronFlutter.gotoLastPage();
if (pageChanged) {
  print("Successfully went to last page");
}
```

#### openGoToPageView
Opens a go-to page dialog. If the user inputs a valid page number into the dialog, the viewer will go to that page.

Returns a Future.

```dart
PdftronFlutter.openGoToPageView();
```

### Import/Export Annotations

#### importAnnotationCommand
Imports remote annotation command to local document. The XFDF needs to be a valid command format with `<add>` `<modify>` `<delete>` tags.

Parameters:

Name | Type | Description
--- | --- | ---
xfdfCommand | String | the XFDF command string for import

Returns a Future.

```dart
var xfdfCommand = 'xfdfCommand <?xml version="1.0" encoding="UTF-8"?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><add><circle style="solid" width="5" color="#E44234" opacity="1" creationdate="D:20201218025606Z" flags="print" date="D:20201218025606Z" name="9d0f2d63-a0cc-4f06-b786-58178c4bd2b1" page="0" rect="56.4793,584.496,208.849,739.369" title="PDF" /></add><modify /><delete /><pdf-info import-version="3" version="2" xmlns="http://www.pdftron.com/pdfinfo" /></xfdf>';
PdftronFlutter.importAnnotationCommand(xfdfCommand);
```

#### importAnnotations
Imports XFDF annotation string to current document.

Parameters:

Name | Type | Description
--- | --- | ---
xfdf | String | annotation string in XFDF format for import

Returns a Future.

```dart

var xfdf = '<?xml version="1.0" encoding="UTF-8"?>\n<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">\n\t<annots>\n\t\t<circle style="solid" width="5" color="#E44234" opacity="1" creationdate="D:20190729202215Z" flags="print" date="D:20190729202215Z" page="0" rect="138.824,653.226,236.28,725.159" title="" /></annots>\n\t<pages>\n\t\t<defmtx matrix="1.333333,0.000000,0.000000,-1.333333,0.000000,1056.000000" />\n\t</pages>\n\t<pdf-info version="2" xmlns="http://www.pdftron.com/pdfinfo" />\n</xfdf>';
PdftronFlutter.importAnnotations(xfdf);
```

#### exportAnnotations

Extracts XFDF from the current document. If `annotationList` is null, export all annotations from the document; else export the valid ones specified.

Parameters:

Name | Type | Description
--- | --- | ---
annotationList | List of [`Annot`](/lib/options.dart) | If not null, export the XFDF string for the valid annotations; Otherwise, export the XFDF string for all annotations in the current document.

Returns a Future.

Future Parameters:

Name | Type | Description
-- | -- | --
xfdf | String? | annotation string in XFDF format

Exports all annotations:
```dart
var xfdf = await PdftronFlutter.exportAnnotations(null);
```

Exports specified annotations:
```dart
List<Annot> annotList = new List<Annot>.empty(growable: true);
annotList.add(new Annot('Hello', 1));
annotList.add(new Annot('World', 2));
var xfdf = await PdftronFlutter.exportAnnotations(annotList);
```

### Annotations

#### flattenAnnotations
Flattens the forms and (optionally) annotations in the current document.

Parameters:

Name | Type | Description
--- | --- | ---
formsOnly | bool | Defines whether only forms are flattened. If false, all annotations will be flattened.

Returns a Future.

```dart
PdftronFlutter.flattenAnnotations(true);
```

#### deleteAnnotations
Deletes the specified annotations in the current document.

Parameters:

Name | Type | Description
--- | --- | ---
annotations | List of [`Annot`](/lib/options.dart) | the annotations to be deleted

Returns a Future.

```dart
List<Annot> annotList = new List<Annot>.empty(growable: true);
annotList.add(new Annot('Hello', 1));
annotList.add(new Annot('World', 2));
PdftronFlutter.deleteAnnotations(annotList);
```

#### deleteAllAnnotations
Deletes all annotations in the current document, excluding links and widgets.

Returns a Future.

```dart
PdftronFlutter.deleteAllAnnotations();
```

#### selectAnnotation
Selects the specified annotation in the current document.

Parameters:

Name | Type | Description
--- | --- | ---
annotation | [`Annot`](/lib/options.dart) | the annotation to be selected

Returns a Future.

```dart
PdftronFlutter.selectAnnotation(new Annot('Hello', 1));
```

#### setFlagsForAnnotations
Sets flags for specified annotations in the current document.

Parameters:

Name | Type | Description
--- | --- | ---
annotationWithFlagsList | List of [`AnnotWithFlags`](/lib/options.dart) | a list of annotations with respective flags to be set

Returns a Future.

```dart
List<AnnotWithFlags> annotsWithFlags = new List<AnnotWithFlags>.empty(growable: true);

Annot hello = new Annot('Hello', 1);
Annot world = new Annot('World', 3);
AnnotFlag printOn = new AnnotFlag(AnnotationFlags.print, true);
AnnotFlag unlock = new AnnotFlag(AnnotationFlags.locked, false);

// you can add an AnnotWithFlags object flexibly like this:
annotWithFlags.add(new AnnotWithFlags.fromAnnotAndFlags(hello, [printOn, unlock]));
annotWithFlags.add(new AnnotWithFlags.fromAnnotAndFlags(world, [unlock]));

// Or simply use the constructor like this:
annotsWithFlags.add(new AnnotWithFlags('Pdftron', 10, AnnotationFlags.no_zoom, true));
PdftronFlutter.setFlagsForAnnotations(annotsWithFlags);
```

#### setPropertiesForAnnotation
Sets properties for specified annotation in the current document.

Parameters:
Name | Type | Description
--- | --- | ---
annotation | [`Annot`](/lib/options.dart) | the annotation to be modified
property | [`AnnotProperty`](/lib/options.dart) | the properties to be set for the target annotation

For settable properties:

Name | Type | Markup exclusive
--- | --- | ---
rect | Rect? | no
contents | String? | no
subject | String? | yes
title | String? | yes
contentRect | Rect? | yes
rotation | int? | no

```dart
Annot pdf = new Annot('pdf', 1);
AnnotProperty property = new AnnotProperty();
property.rect = new Rect.fromCoordinates(1, 1.5, 100.2, 100);
property.contents = 'Hello World';
property.subject = 'sample';
property.title = 'set-props-for-annot';
property.rotation = 90;
PdftronFlutter.setPropertiesForAnnotation(pdf, property);
```

#### groupAnnotations
Groups specified annotations in the current document.

Parameters:
Name | Type | Description
--- | --- | ---
primaryAnnotation | [`Annot`](./lib/options.dart) | the primary annotation of the group
subAnnotations | List of [`Annot`](./lib/options.dart) | the list of annotations to group with the primary annotation

```dart
Annot primaryAnnotation = new Annot(_id1, 1);

List<Annot> subAnnotations = new List<Annot>();
subAnnotations.add(new Annot(_id2, 1));
subAnnotations.add(new Annot(_id3, 1));

PdftronFlutter.groupAnnotations(primaryAnnotation, subAnnotations);
```

#### ungroupAnnotations
Ungroups specified annotations in the current document.

Parameters:
Name | Type | Description
--- | --- | ---
annotations | List of [`Annot`](./lib/options.dart) | the list of annotations to ungroup

```dart
List<Annot> annotations = new List<Annot>();
subAnnotations.add(new Annot(_id1, 1));
subAnnotations.add(new Annot(_id2, 1));

PdftronFlutter.ungroupAnnotations(annotations);
```

#### setFlagForFields
Sets a field flag value on one or more form fields.

Parameters:

Name | Type | Description
--- | ---| ---
fieldNames | List of String | list of field names for which the flag should be set
flag | int | the flag to be set, one of the constants from [`FieldFlags`](/lib/config.dart)
flagValue | bool | value to set for flag

Returns a Future.

```dart
 PdftronFlutter.setFlagForFields(['First Name', 'Last Name'], FieldFlags.Required, true);
```

#### setValuesForFields
Sets field values on one or more form fields of different types.

Parameters:

Name | Type | Description
--- | ---| ---
fields | List of [`Field`](/lib/options.dart) | A list of fields; each field must be set with a name and a value. The value's type can be number, bool or string.

Returns a Future.

```dart
PdftronFlutter.setValuesForFields([
      new Field('textField1', "Pdftron"),
      new Field('textField2', 12.34),
      new Field('checkboxField1', true),
      new Field('checkboxField2', false),
      new Field('radioField', 'Yes'),
      new Field('choiceField', 'No')
    ]);
```

### Navigation

#### handleBackButton
Handles the back button in search mode. Android only.

Returns a Future.

Future Parameters:

Name | Type | Description
--- | --- | ---
handled | bool? | whether the back button is handled successfully

```dart
var handled = await PdftronFlutter.handleBackButton();
print("Back button handled: $handled");
```

### Bookmarks

#### importBookmarkJson
Imports user bookmarks into the document. The input needs to be in valid bookmark JSON format.

Parameters:

Name | Type | Description
--- | --- | ---
bookmarkJson | String | The bookmark json for import. It needs to be in valid bookmark JSON format, for example {"0": "Page 1"}. The page numbers are 1-indexed

Returns a Future.

```dart
PdftronFlutter.importBookmarkJson("{\"0\": \"Page 1\", \"3\": \"Page 4\"}");
```

#### addBookmark
Creates a new bookmark with the given title and page number.

Parameters:

Name | Type | Description
--- | --- | ---
title | String | Title of the bookmark
pageNumber | int | The page number of the new bookmark. It is 1-indexed.

Returns a Future.

```dart
PdftronFlutter.addBookmark("Page 7", 6);
```

#### userBookmarksListEditingEnabled
bool, optional, default value is true

Defines whether the bookmark list can be edited. If the viewer is readonly then bookmarks on Android are
still editable but are saved to the device rather than the PDF.

```dart
config.userBookmarksListEditingEnabled = false;
```

#### Outline

#### outlineListEditingEnabled
bool, optional, default value is true

Defines whether the outline list can be edited.

```dart
config.outlineListEditingEnabled = false;
```

### Navigation

#### showNavigationListAsSidePanelOnLargeDevices
bool, optional, defaults to true

Defines whether the navigation list will be displayed as a side panel on large devices such as iPads and tablets.

```dart
config.showNavigationListAsSidePanelOnLargeDevices = true;
```

### Multi-tab

#### closeAllTabs
Closes all documents that are currently opened in a multiTab environment (that is, [`multiTabEnabled`](#multiTabEnabled) is true in the config).

Returns a Future.

```dart
PdftronFlutter.closeAllTabs();
```

#### openTabSwitcher
Opens the tab switcher in a multi-tab environment.

Returns a Future.

```dart
PdftronFlutter.openTabSwitcher();
```

### Export Images

#### exportAsImage
Export a PDF page to an image format defined in [`ExportFormat`](./lib/constants.dart). The page is taken from the currently opened document in the viewer.

Parameters:

Name | Type | Description
--- | --- | ---
pageNumber | int | the page to be converted
dpi | double | the output image resolution
exportFormat | String | one of [`ExportFormat`](./lib/constants.dart) constants

Returns a Future.

Name | Type | Description
--- | --- | ---
resultImagePath | String | the temp path of the created image, user is responsible for clean up the cache

```dart
var resultImagePath = await PdftronFlutter.exportAsImage(1, 92, ExportFormat.BMP);
```

### Undo/Redo

#### undo
Undo the last modification.

Returns a Future.

```dart
PdftronFlutter.undo();
```

#### redo
Redo the last modification.

Returns a Future.

```dart
PdftronFlutter.redo();
```

#### canUndo
Checks whether an undo operation can be performed from the current snapshot.

Returns a Future.

Name | Type | Description
--- | --- | ---
canUndo | bool | whether it is possible to undo from the current snapshot

```dart
PdftronFlutter.canUndo().then((canUndo) => {
  print("undo possible: $canUndo")
});
```

#### canRedo
Checks whether a redo operation can be perfromed from the current snapshot.

Returns a Future.

Name | Type | Description
--- | --- | ---
canRedo | bool | whether it is possible to redo from the current snapshot

```dart
PdftronFlutter.canRedo().then((canRedo) => {
  print("redo possible: $canRedo")
});
```

## Events
This section contains all the event listeners you could attach to the viewer.

### Document

#### startDocumentLoadedListener
Event is raised when the document finishes loading.

Event Parameters:

Name | Type | Description
--- | --- | ---
path | String | the path to where the document is saved

```dart
var documentLoadedCancel = startDocumentLoadedListener((path)
{
  print("flutter document loaded: $path");
});
```

#### startDocumentErrorListener
Event is raised when the document has errors when loading.

```dart
var documentErrorCancel = startDocumentErrorListener((){
  print("flutter document loaded unsuccessfully");
});
```

### Viewer

#### startLeadingNavButtonPressedListener
Event is raised when the leading navigation button is pressed.

```dart
var navPressedCancel = startLeadingNavButtonPressedListener(()
{
  print("flutter nav button pressed");
});
```

#### documentSliderEnabled
bool, optional, defaults to true

Defines whether the document slider of the viewer is enabled.

```dart
config.documentSliderEnabled = false;
```

### Page

#### startPageChangedListener
Event is raised when the current page changes.

Event Parameters:

Name | Type | Description
--- | --- | ---
previousPageNumber | int | the previous page number
pageNumber | int | the current page number

```dart
var pageChangedCancel = startPageChangedListener((previousPageNumber, pageNumber)
{
  print("flutter page changed. from $previousPageNumber to $pageNumber");
});
```

#### startPageMovedListener
Event is raised when a page has been moved in the document. 

Event Parameters:

Name | Type | Description
--- | --- | ---
previousPageNumber | int | the previous page number
pageNumber | int | the current page number

```dart
var pageMovedCancel = startPageMovedListener((previousPageNumber, pageNumber) {
  print("flutter page moved from $previousPageNumber to $pageNumber");
});
```

### Import/Export Annotations

#### startExportAnnotationCommandListener
Event is raised when local annotation changes are committed to the document.

To also raise this event upon undo/redo, [`annotationManagerEnabled`](#annotationManagerEnabled) must be true, and [`userId`](#userId) must not be null.

Event Parameters:

Name | Type | Description
--- | --- | ---
xfdfCommand | String | the XFDF command string exported

```dart
var annotCancel = startExportAnnotationCommandListener((xfdfCommand) {
  // local annotation changed
  // upload XFDF command to server here
  print("flutter xfdfCommand: $xfdfCommand");
});
```

### Annotations

#### startAnnotationChangedListener
Event is raised when there is a change to annotations to the document.

Event Parameters:

Name | Type | Description
--- | --- | ---
action | String | the action that occurred (add, delete, modify)
annotations | List of [`Annot`](/lib/options.dart) | the annotations that have been changed

```dart
var annotChangedCancel = startAnnotationChangedListener((action, annotations) 
{
  print("flutter annotation action: ${action}");
  for (Annot annot in annotations) {
    print("annotation has id: ${annot.id}");
    print("annotation is in page: ${annot.pageNumber}");
  }
});
```

#### startAnnotationsSelectedListener
Event is raised when annotations are selected.

Event Parameters:

Name | Type | Description
--- | --- | ---
annotationWithRects | List of [`AnnotWithRect`](/lib/options.dart) | The list of annotations with their respective rects

```dart
var annotsSelectedCancel = startAnnotationsSelectedListener((annotationWithRects) 
{
  for (AnnotWithRect annotWithRect in annotationWithRects) {
    print("annotation has id: ${annotWithRect.id}");
    print("annotation is in page: ${annotWithRect.pageNumber}");
    print("annotation has width: ${annotWithRect.rect.width}");
  }
});

```

#### startFormFieldValueChangedListener
Event is raised when there are changes to form field values.

Event Parameters:

Name | Type | Description
--- | --- | ---
fields | List of [`Field`](/lib/options.dart) | the fields that are changed

```dart
var fieldChangedCancel = startFormFieldValueChangedListener((fields)
{
  for (Field field in fields) {
    print("Field has name ${field.fieldName}");
    print("Field has value ${field.fieldValue}");
  }
});
```

### Annotation Menu

#### startAnnotationMenuPressedListener
Event is raised on annotation menu pressed if it is passed into [`overrideAnnotationMenuBehavior`](#overrideAnnotationMenuBehavior).

Event Parameters:

Name | Type | Description
--- | --- | ---
annotationMenuItem | one of the [`AnnotationMenuItems`](/lib/options.dart) constants | The menu item that has been pressed
annotations | List of [`Annot`](/lib/options.dart) | The annotations associated with the menu

```dart
var annotationMenuPressedCancel = startAnnotationMenuPressedListener((annotationMenuItem, annotations) 
{
  print("Annotation menu item " + annotationMenuItem + " has been pressed");
  for (Annot annotation in annotations) {
    print("Annotation has id: ${annotation.id}");
    print("Annotation is in page: ${annotation.pageNumber}");
  }
});
```

### Long Press Menu

#### startLongPressMenuPressedListener
Event is raised on long press menu pressed if it is passed into [`overrideLongPressMenuBehavior`](#overrideLongPressMenuBehavior).

Event Parameters:

Name | Type | Description
--- | --- | ---
longPressMenuItem | one of the [`LongPressMenuItems`](/lib/constants.dart) constants | The menu item that has been pressed
longPressText | string | The selected text if pressed on text, empty otherwise

```dart
var longPressMenuPressedCancel = startLongPressMenuPressedListener((longPressMenuItem, longPressText)
{
  print("Long press menu item " + longPressMenuItem + " has been pressed");
  if (longPressText.length > 0) {
    print("The selected text is: " + longPressText);
  }
});
```

### Custom Behavior

#### startBehaviorActivatedListener
Event is raised on certain behaviors, if any is passed into [`overrideBehavior`](#overrideBehavior).

action | String, one of the [`Behaviors`](#Behaviors) constants | The behavior which has been activated
data | map | detailed information regarding the behavior

```dart
var behaviorActivatedCancel = startBehaviorActivatedListener((action, data) {
  print('action is ' + action);
  print('url is ' + data['url']);
```

### Bookmarks

#### startExportBookmarkListener
Event is raised when user bookmark changes are committed to the document.

Event Parameters:

Name | Type | Description
--- | --- | ---
bookmarkJson | String | the bookmark json string exported

```dart
var bookmarkCancel = startExportBookmarkListener((bookmarkJson) {
  print("flutter bookmark: ${bookmarkJson}");
});
```

### Zoom

#### startZoomChangedListener
Event is raised when zoom ratio is changed in the current document.

Event Parameters:

Name | Type | Description
--- | --- | ---
zoom | double | the zoom ratio in the current document viewer

```dart
var zoomChangedCancel = startZoomChangedListener((zoom) 
{
  print("flutter zoom changed. Current zoom is: $zoom");
});
```


## Viewer Configurations
This section is the configuration part of the [`openDocument`](#openDocument) function. You could also refer [here](/lib/config.dart) for all mutable properties.

### Document

#### customHeaders
map<string, string>, defaults to empty.

Defines custom headers to use with HTTP/HTTPS requests.

```dart
config.customHeaders = {'headerName': 'headerValue'};
```

#### readOnly
bool, defaults to false.

Defines whether the viewer is read-only. If true, the UI will not allow the user to edit the document.

```dart
config.readOnly = true;
```

#### defaultEraserType
one of the [`DefaultEraserType`](./lib/constants.dart) constants, optional

Sets the default eraser tool type. Value only applied after a clean install.

Eraser Type | Description
--- | ---
`annotationEraser` | Erases everything as an object; if you touch ink, the entire object is erased.
`hybridEraser` | Erases ink by pixel, but erases other annotation types as objects.
`inkEraser` | Erases ink by pixel only. Android only.

```dart
config.defaultEraserType = DefaultEraserType.inkEraser;
```

#### exportPath
string, optional
Sets the folder path for all save options, this defaults to the app cache path. Android only.
Example:
```dart
config.exportPath = "/data/data/com.pdftron.pdftronflutterexample/cache/test/";
```

#### openUrlPath
string, optional

Sets the cache folder used to cache PDF files opened using a http/https link, this defaults to the app cache path. Android only.
Example:

```dart
config.openUrlPath = "/data/data/com.pdftron.pdftronflutterexample/cache/test/";
```

#### isBase64String
bool, defaults to false.

If true, document in [`openDocument`](#openDocument) will be treated as a base64 string.

When viewing a document initialized with a base64 string (i.e. a memory buffer), a temporary file is created on Android, but not on iOS. (If you need access to a file-backed PDF on iOS, save the base64 string to disk, and open the file located at that path.)

```dart
config.isBase64String = true;
```

#### base64FileExtension
String, defaults to `.pdf`, required if using base64 string of a non-pdf file.

Defines the file extension for the base64 string in document, if [`isBase64String`](#isBase64String) is true.

```dart
config.base64FileExtension = '.jpeg';
```

### UI Customization

#### disabledElements
array of [`Buttons`](/lib/constants.dart) constants, defaults to none.

Defines buttons to be disabled for the viewer.

```dart
var disabledElements = [Buttons.shareButton, Buttons.searchButton];
config.disabledElements = disabledElements;
```

#### disabledTools
array of [`Tools`](/lib/constants.dart) constants, defaults to none.

Defines tools to be disabled for the viewer.

```dart
var disabledTools = [Tools.annotationCreateLine, Tools.annotationCreateRectangle];
config.disabledTools = disabledTools;
```

#### showLeadingNavButton
bool, defaults to true.

Defines whether to show the leading navigation button.

```dart
config.showLeadingNavButton = true;
```

#### downloadDialogEnabled
bool, defaults to true, Android only.

Defines whether the download dialog should be shown.

```dart
config.downloadDialogEnabled = false;
```

### Toolbar Customization

#### annotationToolbars
array of [`CustomToolbar`](/lib/options.dart) objects or [`DefaultToolbars`](/lib/constants.dart) constants.

Defines custom toolbars. If passed in, the set of default toolbars will no longer appear. It is possible to mix and match with default toolbars. See example below:

```dart
// Viewer will use a custom defined toolbar and a default annotate toolbar in this case
var customToolbar = new CustomToolbar('myToolbar', 'myToolbar', [Tools.annotationCreateArrow, Tools.annotationCreateCallout], ToolbarIcons.favorite);
var annotationToolbars = [DefaultToolbars.annotate, customToolbar];
```

#### hideDefaultAnnotationToolbars
array of [`DefaultToolbars`](/lib/constants.dart) constants, defaults to none.

Defines which default annotation toolbars should be hidden. Note that this should be used when [`annotationToolbars`](#annotationToolbars) is not defined.

```dart
// Viewer will use all the default toolbars except annotate or draw in this case
var hideDefaultAnnotationToolbars = [DefaultToolbars.annotate, DefaultToolbars.draw];
config.hideDefaultAnnotationToolbars = hideDefaultAnnotationToolbars;
```

#### hideAnnotationToolbarSwitcher
bool, defaults to false.

Defines whether to show the toolbar switcher in the top toolbar.

```dart
config.hideAnnotationToolbarSwitcher = true;
```

#### initialToolbar
one of the [`DefaultToolbars`](./lib/constants.dart) constants or the `id` of a custom toolbar object, optional, defaults to none.

Defines which [`annotationToolbar`](#annotationToolbars) should be selected when the document is opened.

```dart
config.initialToolbar = DefaultToolbars.view;
```

#### hideTopToolbars
bool, defaults to false.

Defines whether to hide both the top app nav bar and the annotation toolbar.

```dart
config.hideTopToolbars = true;
```

#### hideToolbarsOnTap
bool, defaults to true.

Defines whether an unhandled tap in the viewer should toggle the visibility of the top and bottom toolbars. When false, the top and bottom toolbar visibility will not be toggled and the page content will fit between the bars, if any.

```dart
config.hideToolbarsOnTap = false;
```

#### hideTopAppNavBar
bool, defaults to false.

Defines whether to hide the top navigation app bar.

```dart
config.hideTopAppNavBar = true;
```

#### topAppNavBarRightBar
array of [`Buttons`](./lib/constants.dart) constants, iOS only

Customizes the right bar section of the top app nav bar. If passed in, the default right bar section will not be used.

```dart
config.topAppNavBarRightBar = [Buttons.searchButton, Buttons.moreItemsButton];
```

#### annotationToolbarAlignment
string, one of ToolbarAlignment.Start or ToolbarAlignment.End

Customizes the alignment of the annotation toolbars.

```dart
config.annotationToolbarAlignment = ToolbarAlignment.Start;
```

#### hideBottomToolbar
bool, default to false.

Defines whether to hide the bottom toolbar for the current viewer.

```dart
config.hideBottomToolbar = true;
```

#### bottomToolbar
array of [`Buttons`](./lib/constants.dart) constants, defaults to none.

Defines a custom bottom toolbar. If passed in, the default bottom toolbar will not be used.

Below is the list of supported buttons for each platform:

| `Button` | Android | iOS |
| :----- | :-----: | :-----: |
| `listsButton` | ✅ | ✅ |
| `thumbnailsButton` | ✅ | ✅ |
| `shareButton` | ✅ | ✅ |
| `viewControlsButton` | ✅ | ✅ |
| `reflowModeButton` | ✅ | ✅ |
| `searchButton` | ✅ | ✅ |
| `moreItemsButton` | ❌ | ✅ |

```dart
config.bottomToolbar = [Buttons.reflowModeButton, Buttons.thumbnailsButton];
```

#### hidePresetBar
bool, default to false.

Defines whether to hide the preset bar for the current viewer.

```dart
config.hidePresetBar = true;
```

#### singleLineToolbar
bool, default to false. Android only.

Sets whether to use 2-line toolbar or 1-line toolbar.

```dart
config.singleLineToolbar = true;
```



### Layout

#### fitMode
one of the [`FitModes`](/lib/constants.dart) constants, default value is 'FitWidth'.

Defines the fit mode (default zoom level) of the viewer.

```dart
config.fitMode = FitModes.fitHeight;
```

#### layoutMode
one of the [`LayoutModes`](/lib/constants.dart) constants, default value is 'Continuous'.

Defines the layout mode of the viewer.

```dart
config.layoutMode = LayoutModes.facingCover;
```

#### tabletLayoutEnabled
bool, optional, defaults to true, Android only.

Defines whether the tablet layout should be used on tablets. Otherwise uses the same layout as phones.

```dart
config.tabletLayoutEnabled = true;
```

### Page

#### initialPageNumber
number, optional

Defines the initial page number that viewer displays when the document is opened. Note that page numbers are 1-indexed.

```dart
config.initialPageNumber = 5;
```

#### pageChangeOnTap
bool, defaults to true.

Defines whether the viewer should change pages when the user taps the edge of a page, while the viewer is in a horizontal viewing mode.

```dart
config.pageChangeOnTap = true;
```

#### pageIndicatorEnabled
bool, defaults to true.

Defines whether to show the page indicator for the viewer.

```dart
config.pageIndicatorEnabled = true;
```

#### pageNumberIndicatorAlwaysVisible
bool, defaults to false.

Defines whether the page indicator will always be visible.

```dart
config.pageNumberIndicatorAlwaysVisible = true;
```

### Annotations

#### annotationPermissionCheckEnabled
bool, default to false.

Defines whether annotation's flags will be taken into account when it is selected, for example, an annotation with a locked flag can not be resized or moved.

```dart
config.annotationPermissionCheckEnabled = true;
```

#### annotationAuthor
String.

Defines the author name for all annotations created on the current document. Exported xfdfCommand will include this piece of information.

```dart
config.annotationAuthor = 'PDFTron';
```

#### continuousAnnotationEditing
bool, defaults to true.

If true, the active annotation creation tool will remain in the current annotation creation tool. Otherwise, it will revert to the "pan tool" after an annotation is created.

```dart
config.continuousAnnotationEditing = true;
```

#### selectAnnotationAfterCreation
bool, defaults to true.

Defines whether an annotation is selected after it is created. On iOS, this functions for shape and text markup annotations only.

```dart
config.selectAnnotationAfterCreation = true;
```

#### disableEditingByAnnotationType
array of [`Tools`](./lib/constants.dart) constants, defaults to none.

Defines annotation types that cannot be edited after creation.

```dart
config.disableEditingByAnnotationType = [Tools.annotationCreateTextSquiggly, Tools.annotationCreateTextHighlight, Tools.annotationCreateEllipse];
```

#### annotationsListEditingEnabled
bool, optional, default value is true.

If document editing is enabled, then this value determines if the annotation list is editable.

```dart
config.annotationsListEditingEnabled = false;
```

#### annotationsListFilterEnabled
bool, optional, default value is true, Android only.

Defines whether filtering the annotation list is possible.

```dart
config.annotationsListFilterEnabled = true;
```

#### excludedAnnotationListTypes
array of [`Config.Tools`](./src/Config/Config.ts) constants, optional, defaults to none

Defines types to be excluded from the annotation list.
Example use:

```dart
config.excludedAnnotationListTypes=[Tools.annotationCreateEllipse, Tools.annotationCreateRedaction];
```

### Reflow

#### reflowOrientation
one of [`ReflowOrientation`](./lib/constants.dart) constants, defaults to the viewer's scroll direction.

Sets the scrolling direction of the reflow control.

```dart
config.reflowOrientation = ReflowOrientation.horizontal;
```

#### imageInReflowModEnabled
bool, defaults to true.

Whether to show images in reflow mode.

```dart
config.imageInReflowModeEnabled = false;
```

### Annotation Menu

#### hideAnnotationMenu
array of [`Tools`](/lib/constants.dart) constants, defaults to none

Defines annotation types that will not show the default annotation menu.

```dart
config.hideAnnotationMenu = [Tools.annotationCreateArrow, Tools.annotationEraserTool];
```

#### annotationMenuItems
array of [`AnnotationMenuItems`](/lib/constants.dart) constants, default contains all items

Defines the menu items that can show when an annotation is selected. 

```dart
config.annotationMenuItems = [AnnotationMenuItems.search, AnnotationMenuItems.share];
```

#### overrideAnnotationMenuBehavior
array of [`AnnotationMenuItems`](/lib/constants.dart) constants, defaults to none

Defines the menu items that will skip default behavior when pressed. They will still be displayed in the annotation menu, and the event handler [`startAnnotationMenuPressedListener`](#startAnnotationMenuPressedListener) will be called from which custom behavior can be implemented.

```dart
config.overrideAnnotationMenuBehavior = [AnnotationMenuItems.copy];
```

### Long Press Menu

#### longPressMenuEnabled
bool, defaults to true

Defines whether to show the popup menu of options after the user long presses on text or blank space on the document.

```dart
config.longPressMenuEnabled = false;
```

#### longPressMenuItems
array of [`LongPressMenuItems`](/lib/constants.dart) constants, optional, default contains all the items

Defines menu items that can be shown when long pressing on text or blank space.

```dart
config.longPressMenuItems = [LongPressMenuItems.search, LongPressMenuItems.share];
```

#### overrideLongPressMenuBehavior
array of [`LongPressMenuItems`](/lib/constants.dart) constants, optional, defaults to none

Defines the menu items on long press that will skip default behavior when pressed. They will still be displayed in the long press menu, and the event handler [`startLongPressMenuPressedListener`](#startLongPressMenuPressedListener) will be called where custom behavior can be implemented.

```dart
config.overrideLongPressMenuBehavior = [LongPressMenuItems.copy];
```

### Custom Behavior

#### overrideBehavior
array of [`Behaviors`](/lib/constants.dart) constants, defaults to none.

Defines actions that should skip default behavior, such as external link click. The event handler [`startBehaviorActivatedListener`](#startBehaviorActivatedListener) will be called when the behavior is activated, where custom behavior can be implemented.

```dart
config.overrideBehavior = [Behaviors.linkPress];
```

### Navigation

#### showQuickNavigationButton
bool, defaults to true.

Defines whether the quick navigation buttons will appear in the viewer.

```dart
config.showQuickNavigationButton = false;
```

### Multi-tab

#### multiTabEnabled
bool, defaults to false.

Defines whether viewer will use tabs in order to have more than one document open simultaneously (like a web browser). Calling [`openDocument`](#openDocument) with this value being true will cause a new tab to be opened with the associated document.

```dart
config.multiTabEnabled = true;
```

#### tabTitle
String, default is the file name.

Sets the tab title if [`multiTabEnabled`](#multiTabEnabled) is true. (For Android, tabTitle is only supported on the widget viewer)

```dart
config.tabTitle = 'tab1';
```

#### openSavedCopyInNewTab
bool, optional, default to true, Android only.

Sets whether the new saved file should open after saving.
Example:

```dart
config.multiTabEnabled = true;
config.openSavedCopyInNewTab = false;
```

#### maxTabCount
number, optional, defaults to unlimited

Sets the limit on the maximum number of tabs that the viewer could have at a time. Open more documents after reaching this limit will overwrite the old tabs.

```dart
config.multiTabEnabled = true;
config.maxTabCount={5}
```

### Signature

#### signSignatureFieldsWithStamps
bool, defaults to false.

Defines whether signature fields will be signed with image stamps. This is useful if you are saving XFDF to remote source.

```dart
config.signSignatureFieldsWithStamps = true;
```

#### showSavedSignatures
bool, defaults to true.

Defines whether to show saved signatures for re-use when using the signing tool.

```dart
config.showSavedSignatures = true;
```

#### signaturePhotoPickerEnabled
bool, optional, defaults to true. Android only.

Defines whether to show the option to pick images in the signature dialog.

```dart
config.signaturePhotoPickerEnabled = true;
```

### Thumbnail Browser

#### thumbnailViewEditingEnabled
bool, defaults to true.

Defines whether user can modify the document using the thumbnail view (eg add/remove/rotate pages).

```dart
config.thumbnailViewEditingEnabled = false;
```

#### hideThumbnailFilterModes
array of [`ThumbnailFilterModes`](/lib/constants.dart) constants, defaults to none.

Defines filter Modes that should be hidden in the thumbnails browser.

```dart
config.hideThumbnailFilterModes = [ThumbnailFilterModes.annotated];
```

### View Mode Dialog
#### hideViewModeItems
array of [`ViewModePickerItem`](./lib/constants.dart) constants, optional, defaults to none.

Defines view mode items to be hidden in the view mode dialog.

```dart
config.hideViewModeItems=[ViewModePickerItem.ColorMode, ViewModePickerItem.Crop];
```

### Others

#### autoSaveEnabled
bool, defaults to true.

Defines whether document is automatically saved by the viewer.

```dart
config.autoSaveEnabled = true;
```

#### showDocumentSavedToast
bool, defaults to true, Android only.

Defines whether a toast indicating that the document has been successfully or unsuccessfully saved will appear.

```dart
config.showDocumentSavedToast = false;
```

#### useStylusAsPen
bool, defaults to true.

Defines whether a stylus should act as a pen when in pan mode. If false, it will act as a finger.

```dart
config.useStylusAsPen = true;
```

#### followSystemDarkMode
bool, Android only, defaults to true.

Defines whether the UI will appear in a dark color when the system is dark mode. If false, it will use viewer setting instead.

```dart
config.followSystemDarkMode = false;
```

#### autoResizeFreeTextEnabled
bool, defaults to false.

Defines whether to automatically resize the bounding box of free text annotations when editing.

```dart
config.autoResizeFreeTextEnabled = true;
```

#### restrictDownloadUsage
bool, defaults to false.

Defines whether to restrict data usage when viewing online PDFs.

```dart
config.restrictDownloadUsage = false;
```

#### annotationManagerEnabled
bool, defaults to false.

Defines whether the annotation manager is enabled.

When [`annotationManagerEnabled`](#annotationManagerEnabled) is true, and [`userId`](#userId) is not null, then [`startExportAnnotationCommandListener`](#startExportAnnotationCommandListener) will be raised when the state of the current document's undo/redo stack has been changed.

```dart
config.annotationManagerEnabled = true;
config.userId = "Bob123";
```

#### userId
String.

The unique identifier of the current user.

When [`annotationManagerEnabled`](#annotationManagerEnabled) is true, and [`userId`](#userId) is not null, then [`startExportAnnotationCommandListener`](#startExportAnnotationCommandListener) will be raised when the state of the current document's undo/redo stack has been changed.

```dart
config.annotationManagerEnabled = true;
config.userId = "Bob123";
```

#### userName
String, Android only.

The name of the current user. Used in the annotation manager when [`annotationManagerEnabled`](#annotationManagerEnabled) is true.

```dart
config.annotationManagerEnabled = true;
config.userId = "Bob123";
config.userName = "Bob";
```

#### annotationManagerEditMode
one of the [`AnnotationManagerEditMode`](./lib/constants.dart) constants, optional, default value is `AnnotationManagerEditMode.All`

Sets annotation manager edit mode when [`annotationManagerEnabled`](#annotationManagerEnabled) is true and [`userId`](#userId) is not null.

Mode | Description
--- | ---
`AnnotationManagerEditMode.Own` | In this mode, you can edit only your own changes
`AnnotationManagerEditMode.All` | In this mode, you can edit everyone's changes

```dart
config.annotationManagerEnabled = true;
config.userId = "Sam";
config.annotationManagerEditMode = AnnotationManagerEditMode.Own;
```

#### annotationManagerUndoMode
one of the [`AnnotationManagerUndoMode`](./lib/constants.dart) constants, optional, default value is `AnnotationManagerUndoMode.All`

Sets annotation manager undo mode when [`annotationManagerEnabled`](#annotationManagerEnabled) is true and [`userId`](#userId) is not null.

Mode | Description
--- | ---
`AnnotationManagerUndoMode.Own` | In this mode, you can undo only your own changes
`AnnotationManagerUndoMode.All` | In this mode, you can undo everyone's changes

```dart
config.annotationManagerEnabled = true;
config.userId = "Sam";
config.annotationManagerUndoMode = AnnotationManagerUndoMode.Own;
```

#### exportPath
String, Android only.

Defines the folder path for all save a copy options e.g. "save a password copy" or "save a flattened copy".

```dart
config.exportPath = "/storage/emulated/0/Download";
```

#### openUrlPath
String, Android only.

Defines the cache folder path for open URL files.

```dart
config.openUrlPath = "/storage/emulated/0/Download";
```