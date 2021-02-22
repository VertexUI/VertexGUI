import GfxMath
import VisualAppBase

private func convertAnyStyleValueToDouble(_ input: StyleValue?) -> Double? {
  if let input = input {
    return Double(String(describing: input))
  }
  return nil
}

private func validateStyleValueCanBeDouble(_ input: StyleValue) -> Bool {
  convertAnyStyleValueToDouble(input) != nil
}

private func convertAnyStyleValueToInsets(_ input: StyleValue?) -> Insets? {
  if let input = input {
    if let oneValue = convertAnyStyleValueToDouble(input) {
      return Insets(all: oneValue)
    } else if let insets = input as? Insets {
      return insets
    }
  }
  return nil
}

private func validateStyleValueCanBeInsets(_ input: StyleValue) -> Bool {
  validateStyleValueCanBeDouble(input) || input as? Insets != nil
}

let defaultStylePropertySupportDefinitions = StylePropertySupportDefinitions([
  StylePropertySupportDefinition(
    key: AnyDefaultStyleKeys.foreground,
    validators: StylePropertyValueValidators(typeValidator: .specific(Color.self)),
    defaultValue: SpecialStyleValue.inherit),

  StylePropertySupportDefinition(
    key: AnyDefaultStyleKeys.background,
    validators: StylePropertyValueValidators(typeValidator: .specific(Color.self))),

  StylePropertySupportDefinition(
    key: AnyDefaultStyleKeys.fontSize,
    validators: StylePropertyValueValidators(typeValidator: .function(validateStyleValueCanBeDouble)),
    convertValue: convertAnyStyleValueToDouble,
    defaultValue: SpecialStyleValue.inherit),

  StylePropertySupportDefinition(
    key: AnyDefaultStyleKeys.fontFamily,
    validators: StylePropertyValueValidators(typeValidator: .specific(FontFamily.self)),
    defaultValue: SpecialStyleValue.inherit),

  StylePropertySupportDefinition(
    key: AnyDefaultStyleKeys.fontWeight,
    validators: StylePropertyValueValidators(typeValidator: .specific(FontWeight.self)),
    defaultValue: SpecialStyleValue.inherit),
 
  StylePropertySupportDefinition(
    key: AnyDefaultStyleKeys.fontStyle,
    validators: StylePropertyValueValidators(typeValidator: .specific(FontStyle.self)),
    defaultValue: SpecialStyleValue.inherit),

  StylePropertySupportDefinition(
    key: AnyDefaultStyleKeys.width,
    validators: StylePropertyValueValidators(typeValidator: .function(validateStyleValueCanBeDouble)),
    convertValue: convertAnyStyleValueToDouble),

  StylePropertySupportDefinition(
    key: AnyDefaultStyleKeys.height,
    validators: StylePropertyValueValidators(typeValidator: .function(validateStyleValueCanBeDouble)),
    convertValue: convertAnyStyleValueToDouble),

  StylePropertySupportDefinition(
    key: AnyDefaultStyleKeys.minWidth,
    validators: StylePropertyValueValidators(typeValidator: .function(validateStyleValueCanBeDouble)),
    convertValue: convertAnyStyleValueToDouble),

  StylePropertySupportDefinition(
    key: AnyDefaultStyleKeys.minHeight,
    validators: StylePropertyValueValidators(typeValidator: .function(validateStyleValueCanBeDouble)),
    convertValue: convertAnyStyleValueToDouble),

  StylePropertySupportDefinition(
    key: AnyDefaultStyleKeys.maxWidth,
    validators: StylePropertyValueValidators(typeValidator: .function(validateStyleValueCanBeDouble)),
    convertValue: convertAnyStyleValueToDouble),

  StylePropertySupportDefinition(
    key: AnyDefaultStyleKeys.maxHeight,
    validators: StylePropertyValueValidators(typeValidator: .function(validateStyleValueCanBeDouble)),
    convertValue: convertAnyStyleValueToDouble),

  StylePropertySupportDefinition(
    key: AnyDefaultStyleKeys.padding,
    validators: StylePropertyValueValidators(typeValidator: .function(validateStyleValueCanBeInsets)),
    convertValue: convertAnyStyleValueToInsets),

  StylePropertySupportDefinition(
    key: AnyDefaultStyleKeys.borderWidth,
    validators: StylePropertyValueValidators(typeValidator: .function(validateStyleValueCanBeInsets)),
    convertValue: convertAnyStyleValueToInsets),
])
