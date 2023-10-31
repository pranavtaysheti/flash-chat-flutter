import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String message = "";

  @override
  void initState() {
    super.initState();
    if (currentUser == null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  if (FirebaseAuth.instance.currentUser == null) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  print(e);
                }
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: (currentUser != null)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("messages")
                        .snapshots(),
                    builder: (context, snapshot) {
                      List<MessageBubble> messageWidgets = [];

                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      List<QueryDocumentSnapshot<Map<String, dynamic>>>?
                          queryData = snapshot.data?.docs.reversed.toList();
                      if (queryData != null) {
                        for (var doc in queryData) {
                          messageWidgets.add(
                            MessageBubble(
                              sender: currentUser?.email ?? "Anonymous",
                              message: doc.data()["message"],
                              isMe: true,
                            ),
                          );
                        }
                        return Expanded(
                          child: ListView(
                            reverse: true,
                            children: messageWidgets,
                          ),
                        );
                      }
                      return Placeholder();
                    },
                  ),
                  Container(
                    decoration: kMessageContainerDecoration,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              message = value;
                            },
                            decoration: kMessageTextFieldDecoration,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection("messages")
                                .add({
                              "message": message,
                              "sender":
                                  FirebaseAuth.instance.currentUser?.email,
                            });
                            setState(() {
                              message = "";
                            });
                          },
                          child: Text(
                            'Send',
                            style: kSendButtonTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String message;
  final bool isMe;

  const MessageBubble({
    required this.sender,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
