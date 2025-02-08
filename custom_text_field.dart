class CustomTextField extends StatelessWidget {
  final double height;
  final TextEditingController tEController;
  final TextInputType textInputType;
  final String? labelText;
  final Widget? suffixIcon;
  final Widget? preIcon;
  final Function()? onTap;
  final Function(String)? onChange;
  final List<TextInputFormatter>? inputFormatter;
  final RxString? errorText;
  final bool isReadOnly;
  final EdgeInsetsGeometry? contentPadding;
  final String hintText, title;
  final int? minLines, maxLines, maxLength;
  final bool isMandatory, isEnabled, isBorderLess ,isExpand;
  final String? Function(String)? validator;
  final RxBool obscureText, isFocused;
  final Color? borderColor,textFieldColor;

  CustomTextField(
    this.hintText,
    this.tEController, {
    this.textInputType = TextInputType.text,
    this.isMandatory = false,
    this.isEnabled = true,
    this.isBorderLess = false,
    this.title = '',
    this.height = 40.0,
    this.labelText,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.suffixIcon,
    this.preIcon,
    this.onTap,
    this.onChange,
    this.errorText,
    this.isReadOnly = false,
    this.isExpand = false,
    this.contentPadding,
    this.inputFormatter,
    this.validator,
    this.borderColor,
        this.textFieldColor,
    RxBool? isFocused,
    RxBool? obscureText,
    super.key,
  })  : obscureText = obscureText ?? false.obs,
        isFocused = false.obs;

  @override
  Widget build(BuildContext context) {
    final RxString effectiveErrorText = errorText ?? ''.obs;

    return Semantics(
      label: hintText,
      tooltip: hintText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Row(
              children: [
                CustomText(title, ConstantsFile.smallCaptionFontSize, ColorFile.blackColor, ConstantsFile.mediumFontFamily),
                if (isMandatory) _mandatoryIndicator(),
              ],
            ),
          if (title.isNotEmpty) SizedBox(height: 4.h),
          Obx(() {
            final decoration = _getBoxDecoration(isFocused.value, errorText?.value ?? "", isBorderLess);

            return Focus(
              autofocus: true,
              canRequestFocus: isEnabled,
              onFocusChange: (focused) {
                isFocused.value = focused;
                if (!focused) {
                  final error = validator?.call(tEController.text);
                  effectiveErrorText.value = error ?? '';
                }
              },
              child: Container(
                decoration: decoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        height: height.h,
                        child: TextField(
                         cursorColor: ColorFile.darkThemeColor,
                          expands: isExpand,
                            onChanged: (value) {
                              onChange?.call(value);
                              if (validator != null) {
                                final error = validator!(value);
                                effectiveErrorText.value = error ?? '';
                              } else {
                                effectiveErrorText.value = '';
                              }
                            },
                            controller: tEController,
                            keyboardType: textInputType,
                            enabled: isEnabled,
                            obscureText: obscureText.value,
                            inputFormatters: inputFormatter,
                            minLines: minLines,
                            maxLines:isExpand ? null : maxLines,
                            onTap: onTap,
                            readOnly: isReadOnly,
                            autocorrect: false,
                            style: _textStyle(isEnabled),
                            decoration: InputDecoration(
                                fillColor: ColorFile.appBgColor,
                                border: InputBorder.none,
                                icon: preIcon,
                                suffixIcon: suffixIcon,
                                labelText: labelText,
                                counterText: '',
                                hintText: hintText,
                                labelStyle: _labelStyle(),
                                hintStyle: _hintStyle(),
                                contentPadding: contentPadding ?? EdgeInsets.symmetric(vertical: 12.w, horizontal: 12.w),
                                isDense: true),
                            maxLength: maxLength)),
                    if (effectiveErrorText.value.isNotEmpty) _errorTextWidget(effectiveErrorText.value)
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _mandatoryIndicator() {
    return CustomText(' *', ConstantsFile.smallCaptionFontSize, ColorFile.errorColor, ConstantsFile.mediumFontFamily);
  }

  Widget _errorTextWidget(String errorText) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
        width: Get.width,
        color: ColorFile.errorColor,
        child: CustomText(errorText, ConstantsFile.smallFontSize, ColorFile.whiteColor, ConstantsFile.regularFontFamily));
  }

  TextStyle _textStyle(bool isEnabled) => TextStyle(
      fontSize: ConstantsFile.smallCaptionFontSize,
      color: isEnabled ? ColorFile.blackColor : ColorFile.blackColorOpaque70,
      fontFamily: ConstantsFile.regularFontFamily);

  TextStyle _labelStyle() => TextStyle(
      fontSize: ConstantsFile.smallCaptionFontSize, color: ColorFile.blackColor, fontFamily: ConstantsFile.semiBoldFontFamily);

  TextStyle _hintStyle() => TextStyle(
      fontSize: ConstantsFile.smallCaptionFontSize,
      color: ColorFile.sliderLightColor,
      fontFamily: ConstantsFile.regularFontFamily);

  BoxDecoration _getBoxDecoration(bool isFocused, String effectiveErrorText, bool isBorderLess) {
    final BorderSide outlineBorderSide =
        BorderSide(color: borderColor ?? (isFocused ? ColorFile.themeColor : ColorFile.textFieldBorderColor));
    final BorderSide errorBorderSide = BorderSide(color: ColorFile.errorColor);

    final double borderWidth = effectiveErrorText.isNotEmpty ? 2.0 : (isFocused ? 1.5 : 1.0);
    final BoxBorder border =
        Border.all(color: effectiveErrorText.isNotEmpty ? errorBorderSide.color : outlineBorderSide.color, width: borderWidth);

    return isBorderLess
        ? const BoxDecoration()
        : BoxDecoration(color: textFieldColor ?? ColorFile.appBgColor, border: border, borderRadius: BorderRadius.all(Radius.circular(6.r)));
  }
}
