import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showAlertDialog(BuildContext context, String question, Function onSubmit) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            backgroundColor: Theme.of(context).accentColor,
            title: Text(
              "Are you sure?",
              style: GoogleFonts.lato(fontWeight: FontWeight.bold),
            ),
            content: Text(question),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              TextButton(
                  child: Text(
                    "Close",
                    style: GoogleFonts.lato(color: Colors.black54),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),

              TextButton(
                  child: Text(
                    'Submit',
                    style: GoogleFonts.lato(color: Colors.black),
                  ),
                  onPressed: onSubmit as void Function()?)
            ]);
      });
}
