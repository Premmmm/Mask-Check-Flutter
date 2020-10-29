import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';

class DecisionScreen extends StatefulWidget {
  final String imagePath;
  final String label;
  final double conf;
  DecisionScreen({this.imagePath, this.label, this.conf});

  @override
  _DecisionScreenState createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1B20),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('images/bg.jpg'), fit: BoxFit.cover)),
          child: ListView(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.file(
                  File(widget.imagePath),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  '${widget.label}',
                  style: TextStyle(fontSize: 30),
                ),
              ),
              Center(
                child: Text(
                  'Confidence: ${widget.conf.toStringAsPrecision(3)}' + '%',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
