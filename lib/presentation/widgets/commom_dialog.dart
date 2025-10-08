import 'package:bulletin_board/l10n/app_localizations.dart';
import 'package:bulletin_board/presentation/widgets/custom_text_field.dart';
import 'package:bulletin_board/validators/validators.dart';
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String msg, MaterialColor? color) {
  final Widget toastWithButton = Container(
    padding: const EdgeInsets.only(left: 19),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: color ?? const Color(0xFF1E1A1A),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            msg,
            softWrap: true,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const ColoredBox(
          color: Color(0xFFF4F4F4),
          child: SizedBox(
            width: 1,
            height: 23,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.close,
            size: 20,
          ),
          color: const Color(0xFFF61202),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ],
    ),
  );
  final snackBar = SnackBar(
    content: toastWithButton,
    backgroundColor: Colors.transparent,
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.zero,
    elevation: 0,
    duration: const Duration(milliseconds: 5000),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<void> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String confirmText,
  required IconData confirmIcon,
  required Color confirmColor,
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
          ],
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          icon: Icon(confirmIcon, color: Colors.white),
          label: Text(confirmText, style: const TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
          ),
        ),
        const SizedBox(width: 20),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close, color: Colors.white),
          label: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
        ),
      ],
    ),
  );
}

Future<void> showEmailVerifiedDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  required Future<void> Function() onSave,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      bool isLoading = false;

      return StatefulBuilder(
        builder: (BuildContext context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.white,
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            content: content,
            actions: <Widget>[
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF017256),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          try {
                            await onSave();
                          } on Exception catch (e) {
                            if (context.mounted) {
                              showSnackBar(context, e.toString(),
                                  Colors.red);
                            }
                          } finally {
                            if (context.mounted) {
                              setState(() => isLoading = false);
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.goLogin,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> accountDeleteConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required Function(String? password)? okFunction,
  String? okButton,
  bool password = false,
  TextEditingController? passwordController,
  required String cancelButton,
}) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      final ValueNotifier<bool> isPasswordVisible = ValueNotifier(false);
      final formKey = GlobalKey<FormState>();
      final controller = passwordController ?? TextEditingController();

      return Form(
        key: formKey,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Text(message, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                if (password)
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 5),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.enterPassword,
                          style: const TextStyle(fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        ValueListenableBuilder<bool>(
                          valueListenable: isPasswordVisible,
                          builder: (context, value, child) {
                            return TextFormField(
                              controller: controller,
                              obscureText: !value,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.password,
                                suffixIcon: IconButton(
                                  icon: Icon(value ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => isPasswordVisible.value = !value,
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return AppLocalizations.of(context)!.enterPassword;
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    child: Text(cancelButton,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.lightGreen)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                if (okButton != null && okButton.isNotEmpty)
                  Expanded(
                    child: TextButton(
                      child: Text(okButton,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.w700)),
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          Navigator.of(context).pop();
                          if (okFunction != null) okFunction(controller.text);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Future<String?> showAdminPasswordDialog(BuildContext context) async {
  final TextEditingController passwordController = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Enter Admin Password"),
      content: CustomTextField(
        controller: passwordController,
        label: AppLocalizations.of(context)!.password,
        isRequired: true,
        maxLength: 26,
        validator: (value) => Validators.validatePassword(
            value: value,
            labelText: AppLocalizations.of(context)!.enterPassword,
            context: context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, passwordController.text),
          child: const Text("Confirm"),
        ),
      ],
    ),
  );
}
