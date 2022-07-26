import 'dart:ui';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:pingolearntask/service/data-service.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isLoading = true;
  String _listernedWord = '';
  String _localeId = '';

  @override
  void initState() {
    super.initState();
    //_initSpeech();
  }

  Future<void> _initSpeech() async {
     try{
       var speechEnabled = await _speechToText.initialize(
           onError: errorListner,
           debugLogging: true,
           onStatus: statusListner).then((value) {
            // print(value.toString());
       });
       if(_speechEnabled){
         var systemLocale = await _speechToText.systemLocale();
         _localeId = systemLocale?.localeId??"";
       }
       setState((){
         _speechEnabled = speechEnabled;
       });
     }catch(error){
      // print("error ${error.toString()}");
     }
    setState(() {});
  }

  void _startListerning() async {

    await _speechToText.listen(
        onResult: onSpeechResult,
        partialResults: true,
        cancelOnError: true,
        onDevice: true,
        localeId: _localeId,
        listenMode: ListenMode.confirmation,
        listenFor: Duration(seconds: 10));
    setState(() {});
  }

  void _stopListerning() async {
    await _speechToText.stop();
    setState(() {});
  }

  void errorListner(SpeechRecognitionError error){
    print("Speech Error: \n${error.errorMsg}");
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    print(result.recognizedWords);
    setState(() {
      _listernedWord = result.recognizedWords;
      _searchController.text = result.recognizedWords;
    });
  }

  void statusListner(String status){
    print(status);
  }

  showLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    final movieDetail = Provider.of<DataService>(context).movieList;

    print(movieDetail);
    return _isLoading
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.amber.shade300,
              centerTitle: true,
              title: const Text("Pingo Learn",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.black)),
              elevation: 22,
              shadowColor: Colors.yellow,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                  child: TextFormField(
                    autofocus: true,
                    controller: _searchController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      label: const Text("Search Movie"),
                      labelStyle: const TextStyle(color: Colors.black),
                      alignLabelWithHint: true,
                      contentPadding: const EdgeInsets.only(
                          left: 8, top: 8, right: 8, bottom: 8),
                      prefix: /*IconButton(icon: const, onPressed: () {  },),*/
                          Container(
                        transform: Matrix4.translationValues(0, 5, 0),
                        child: InkWell(
                          onTap: () {
                            //_initSpeech();
                            /*if(_speechEnabled *//*|| _speechToText.isListening*//* || _speechToText.isAvailable){*/
                            _initSpeech().then((value) {
                              print(_speechToText.isAvailable);
                            });
                            /*}else{
                              _stopListerning;
                            }*/
                          },
                          child: const Icon(Icons.mic, size: 50),
                        ),
                      ),
                      isDense: true,
                      suffix: Container(
                        transform: Matrix4.translationValues(0, 5, 0),
                        child: InkWell(
                          onTap: () {
                            if (_searchController.text.trim().isNotEmpty) {
                              showLoading();
                              Provider.of<DataService>(context, listen: false)
                                  .getMovies(_searchController.text, context)
                                  .then((value) {
                                showLoading();
                              });
                            }
                          },
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: FlipCard(
                    direction: FlipDirection.HORIZONTAL,
                    front: Material(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      shadowColor: const Color(0x802196F3).withOpacity(0.2),
                      child: _nameDetailContainer(movieDetail),
                    ),
                    back: Material(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      shadowColor: const Color(0x802196F3).withOpacity(0.2),
                      child: _overviewDetailContainer(movieDetail),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 8,
                  ),
                  Text("Getting Movie List...")
                ],
              ),
            ),
          );
  }
}

Widget _nameDetailContainer(var movieDetail) {
  return Stack(
    alignment: Alignment.bottomCenter,
    children: [
      Container(
        height: 550,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.network(
          movieDetail["image"],
          fit: BoxFit.cover,
        ),
      ),
      Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black, Colors.black87],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 10,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 125),
                child: Text(
                  movieDetail["title"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "Release date: ${movieDetail["release_date"]}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Rating: ${movieDetail["rating"]}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 125),
                child: Text(
                  "[Please tap to flip]",
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      )
    ],
  );
}

Widget _overviewDetailContainer(var movieDetail) {
  return Stack(
    children: [
      Container(
        height: 550,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.network(
          movieDetail['image'],
          fit: BoxFit.cover,
        ),
      ),
      Container(
        height: 550,
        width: double.infinity,
        padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black54,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Story",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 23),
            ),
            Text(
              movieDetail['story'],
              style: const TextStyle(color: Colors.white, fontSize: 23),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                "[Please tap to flip]",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
