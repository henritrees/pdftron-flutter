part of pdftron;

class Config {
  var _disabledElements;
  var _disabledTools;
  var _multiTabEnabled;
  var _customHeaders;
  var _fitMode;
  var _layoutMode;
  var _initialPageNumber;
  var _isBase64;
  var _showLeadingNavButton;
  var _readOnly;
  var _thumbnailViewEditingEnabled;
  var _annotationAuthor;
  var _continuousAnnotationEditing;

  Config();

  set disabledElements(List value) => _disabledElements = value;
  set disabledTools(List value) => _disabledTools = value;
  set multiTabEnabled(bool value) => _multiTabEnabled = value;
  set customHeaders(Map<String, String> value) => _customHeaders = value;
  set fitMode(String value) => _fitMode = value;
  set layoutMode(String value) => _layoutMode = value;
  set initialPageNumber(int value) => _initialPageNumber = value;
  set isBase64(bool value) => _isBase64 = value;
  set showLeadingNavButton(bool value) => _showLeadingNavButton = value;
  set readOnly(bool value) => _readOnly = value;
  set thumbnailViewEditingEnabled(bool value) =>
      _thumbnailViewEditingEnabled = value;
  set annotationAuthor(String value) => _annotationAuthor = value;
  set continuousAnnotationEditing(bool value) =>
      _continuousAnnotationEditing = value;

  Config.fromJson(Map<String, dynamic> json)
      : _disabledElements = json['disabledElements'],
        _disabledTools = json['disabledTools'],
        _multiTabEnabled = json['multiTabEnabled'],
        _customHeaders = json['customHeaders'],
        _fitMode = json['fitMode'],
        _layoutMode = json['layoutMode'],
        _initialPageNumber = json['initialPageNumber'],
        _isBase64 = json['isBase64'],
        _showLeadingNavButton = json['showLeadingNavButton'],
        _readOnly = json['readOnly'],
        _thumbnailViewEditingEnabled = json['thumbnailViewEditingEnabled'],
        _annotationAuthor = json['annotationAuthor'],
        _continuousAnnotationEditing = json['continuousAnnotationEditing'];

  Map<String, dynamic> toJson() => {
        'disabledElements': _disabledElements,
        'disabledTools': _disabledTools,
        'multiTabEnabled': _multiTabEnabled,
        'customHeaders': _customHeaders,
        'fitMode': _fitMode,
        'layoutMode': _layoutMode,
        'initialPageNumber': _initialPageNumber,
        'isBase64': _isBase64,
        'showLeadingNavButton': _showLeadingNavButton,
        'readOnly': _readOnly,
        'thumbnailViewEditingEnabled': _thumbnailViewEditingEnabled,
        'annotationAuthor': _annotationAuthor,
        'continuousAnnotationEditing': _continuousAnnotationEditing,
      };
}
