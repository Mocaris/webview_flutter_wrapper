# Version History

## 0.0.2
- Unify the naming specifications for JS callback functions and rename the_callNative method to_callNativeFunc
- Remove duplicate callNative function definitions and extract them into a unified_commCallbackJs function
- Optimize page loading event listeners and add removeEventListener to avoid repeated triggers
- Update the case specification for object names in the sample code, change InjectStart to InjectStart
- Modify the name of the communication bridge channel and change_webviewHandleJsObject to_injectFuncHandleJsObject
- Simplify function call logic and replace conditional judgment with optional chain operators
- Update event listener name case specifications in documentation and examples
- Fixed listener removal logic for page script ready events

## 0.0.1

- adjustment WebviewWrapperController api
- fix: any bugs
