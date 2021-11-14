import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/api_helper.dart';
import 'package:madeupu_app/helpers/app_colors.dart';
import 'package:madeupu_app/models/city.dart';
import 'package:madeupu_app/models/comments.dart';
import 'package:madeupu_app/models/country.dart';
import 'package:madeupu_app/models/participation_type.dart';
import 'package:madeupu_app/models/participations.dart';
import 'package:madeupu_app/models/project.dart';
import 'package:madeupu_app/models/project_category.dart';
import 'package:madeupu_app/models/region.dart';
import 'package:madeupu_app/models/response.dart';
import 'package:madeupu_app/models/token.dart';
import 'package:madeupu_app/screens/comment_screen.dart';
import 'package:madeupu_app/screens/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ProjectViewScreen extends StatefulWidget {
  final Project project;
  final Token token;
  // ignore: use_key_in_widget_constructors
  const ProjectViewScreen({required this.project, required this.token});

  @override
  _ProjectViewScreenState createState() => _ProjectViewScreenState();
}

class _ProjectViewScreenState extends State<ProjectViewScreen> {
  bool _showLoader = false;
  int _current = 0;
  final CarouselController _carouselController = CarouselController();
  List<Comments> _comments = [];
  Project _project = Project(
      id: 0,
      city: City(
          id: 0,
          name: '',
          region: Region(id: 0, name: '', country: Country(id: 0, name: ''))),
      projectCategory: ProjectCategory(id: 0, description: ''),
      name: '',
      website: '',
      address: '',
      beginAt: '',
      description: '',
      imageFullPath: '',
      ratingsNumber: 0,
      averageRating: 0,
      participations: [],
      projectPhotos: [],
      ratings: [],
      comments: [],
      video: '',
      videoCode: '');
  bool _qualifiable = false;
  bool _participable = false;
  bool _somethingNew = false;

  int _participationTypeId = 0;
  String _participationTypeIdError = '';
  bool _participationTypeIdShowError = false;
  List<ParticipationType> _participationTypes = [];

  String _message = '';
  String _messageError = '';
  bool _messageShowError = false;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _participatinTypeTypes();
    _comments = widget.project.comments;
    _project = widget.project;
    _qualifiable = _valideUserHasRated();
    _participable = _valideUserIsParticipating();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _somethingNew
            ? Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(token: widget.token)),
              )
            : Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              widget.project.id == 0 ? 'New project' : widget.project.name),
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _showPhoto(),
                  _showProjectName(),
                  _showCategories(),
                  _showProjectWebsite(),
                  _showProjectAddress(),
                  _showProjectBeginAt(),
                  _showCities(),
                  _showProjectCreatorName(),
                  _showCreatorPhoneNumber(),
                  _showCreatorWhatsApp(),
                  _showProjectDescription(),
                  _showProjectVideo(),
                  _showPhotosCarousel(),
                  _showRating(),
                  _showComments(),
                  _showParticipation()
                ],
              ),
            ),
            _showLoader
                ? const LoaderComponent(
                    text: 'Please wait...',
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  bool _valideUserHasRated() {
    for (var e in _project.ratings) {
      if (widget.token.user.userName == e.user.userName) {
        return false;
      }
    }
    return true;
  }

  bool _valideUserIsParticipating() {
    for (var e in _project.participations) {
      if (widget.token.user.userName == e.user.userName) {
        return false;
      }
    }
    return true;
  }

  String _creatorUser(List<Participations> participations) {
    for (var e in participations) {
      if (e.participationType.description == 'Creador') {
        return e.user.userName;
      }
    }
    return widget.token.user.userName;
  }

  _showPhoto() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 20),
        child: widget.project.imageFullPath.isEmpty
            ? const Image(
                image: AssetImage('assets/noimage.png'),
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: FadeInImage(
                    placeholder: const AssetImage('assets/logo.png'),
                    image: NetworkImage(widget.project.imageFullPath),
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _showProjectName() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Project: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            widget.project.name,
            style: const TextStyle(fontSize: 19),
          )
        ],
      ),
    );
  }

  Widget _showCategories() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text(
              'Category: ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              widget.project.projectCategory.description,
              style: const TextStyle(fontSize: 20),
            ),
          ]),
    );
  }

  Widget _showProjectWebsite() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text(
              'Website: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Row(
              children: [
                InkWell(
                  onTap: () => _launchURL(widget.project.website.toString()),
                  child: const Text(
                    'Visit the official website',
                    style: TextStyle(fontSize: 19),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Icon(
                  Icons.link,
                  color: Color(0xFF16BCEC),
                )
              ],
            )
          ]),
    );
  }

  void _launchURL(String url) async {
    await launch(url);
  }

  Widget _showProjectAddress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Address: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            widget.project.address,
            style: const TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }

  Widget _showProjectBeginAt() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Start date: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            DateFormat.yMMMMd().format(DateTime.parse(widget.project.beginAt)),
            style: const TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }

  Widget _showCities() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Location: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            '${widget.project.city.name}, ${widget.project.city.region.country.name}',
            style: const TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }

  Widget _showRating() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(bottom: 5),
                child: const Text('Rating: ',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Total ratings: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    '${_project.ratingsNumber}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Average Rating: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    '${_project.averageRating}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
          _showRatingStars()
        ],
      ),
    );
  }

  Widget _showRatingStars() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: _qualifiable
          ? RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              itemSize: 40,
              direction: Axis.horizontal,
              allowHalfRating: false,
              unratedColor: AppColors.gray,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 5.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: AppColors.darkblue,
              ),
              onRatingUpdate: (rating) {
                _addRating(rating.toInt());
              },
            )
          : const Text('Ya calificaste este proyecto'),
    );
  }

  Widget _showProjectCreatorName() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Owner: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            _getOwnerName(),
            style: const TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }

  String _getOwnerName() {
    for (var element in widget.project.participations) {
      if (element.participationType.description == 'Creador') {
        return element.user.fullName;
      }
    }
    return '';
  }

  String _getOwnerPhone() {
    for (var element in widget.project.participations) {
      if (element.participationType.description == 'Creador') {
        return element.user.phoneNumber;
      }
    }
    return '';
  }

  Widget _showCreatorPhoneNumber() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Phone: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            _getOwnerPhone(),
            style: const TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }

  Widget _showCreatorWhatsApp() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Contact by: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          _showContactuttons(),
        ],
      ),
    );
  }

  Widget _showContactuttons() {
    return Row(
      children: <Widget>[
        ClipRRect(
          child: IconButton(
            icon: const Icon(
              Icons.call,
              color: Colors.blue,
            ),
            onPressed: () => launch('tel://${_getOwnerPhone()}'),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Colors.green,
            ),
            onPressed: () => _sendMessage(),
          ),
        ),
      ],
    );
  }

  void _sendMessage() async {
    final link = WhatsAppUnilink(
      phoneNumber: _getOwnerPhone(),
      text: 'Hello, I want to be part of your project.',
    );
    await launch('$link');
  }

  Widget _showProjectDescription() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: const <Widget>[
              Text(
                'Description: ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            ],
          ),
          SizedBox(
            height: 200,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(
                widget.project.description,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showProjectVideo() {
    late YoutubePlayerController _controller;
    _controller = YoutubePlayerController(
        initialVideoId: widget.project.videoCode,
        params: const YoutubePlayerParams(
          loop: false,
          color: 'transparent',
          desktopMode: true,
          strictRelatedVideos: true,
          autoPlay: false,
          showFullscreenButton: !kIsWeb,
        ));
    final screensize = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
            child: Row(
              children: const <Widget>[
                Text(
                  'Project video pitch: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                )
              ],
            ),
          ),
          SizedBox(
            width: screensize.width,
            child: YoutubePlayerControllerProvider(
              controller: _controller,
              child: YoutubePlayerIFrame(
                controller: _controller,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _showPhotosCarousel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              children: const <Widget>[
                Text(
                  'Presentation images: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )
              ],
            ),
          ),
          CarouselSlider(
            options: CarouselOptions(
                height: 350,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
            carouselController: _carouselController,
            items: widget.project.projectPhotos.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: i.imageFullPath,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          fit: BoxFit.cover,
                          height: 300,
                          width: 300,
                          placeholder: (context, url) => const Image(
                            image: AssetImage('assets/logo.png'),
                            fit: BoxFit.cover,
                            height: 300,
                            width: 300,
                          ),
                        ),
                      ));
                },
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.project.projectPhotos.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _carouselController.animateToPage(entry.key),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _showComments() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: const <Widget>[
              Text(
                'Comments: ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            ],
          ),
          _comments.isNotEmpty
              ? SizedBox(
                  height: 325,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      height: 325,
                      child: ListView.builder(
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 5, top: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: index % 2 == 0
                                    ? AppColors.darkblue
                                    : AppColors.blue,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: Row(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    _showCommentUserPhoto(
                                        _comments[index].user.imageFullPath),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      _comments[index].user.fullName,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                  child: Text(
                                    _comments[index].message,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
              : const Text(
                  'There is no comments right now.',
                  style: TextStyle(fontSize: 16),
                ),
          ElevatedButton(
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Comment  ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppColors.white),
                    ),
                    const Icon(Icons.message)
                  ],
                )),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                return AppColors.darkblue;
              }),
            ),
            onPressed: () => _addComment(),
          )
        ],
      ),
    );
  }

  void _addComment() async {
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CommentScreen(project: widget.project, token: widget.token)),
    );
    if (result == 'yes') {
      _somethingNew = true;
      _getProject();
    }
  }

  Future<void> _getProject() async {
    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Verify that you are connected to the internet.',
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }

    Response response = await ApiHelper.getProjectById(
        widget.token, widget.project.id.toString());

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }

    setState(() {
      _comments = response.result.comments;
      _project = response.result;
    });
  }

  Widget _showCommentUserPhoto(String imageUrl) {
    return Stack(children: <Widget>[
      Container(
        margin: const EdgeInsets.only(top: 10),
        child: imageUrl.isEmpty
            ? const Image(
                image: AssetImage('assets/noimage.png'),
                height: 90,
                width: 90,
                fit: BoxFit.cover,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                  height: 90,
                  width: 90,
                  placeholder: (context, url) => const Image(
                    image: AssetImage('assets/icono.png'),
                    fit: BoxFit.cover,
                    height: 90,
                    width: 90,
                  ),
                ),
              ),
      ),
    ]);
  }

  void _addRating(int rateValue) async {
    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Verify that you are connected to the internet.',
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }

    Map<String, dynamic> request = {
      'Rate': rateValue,
      'ProjectId': widget.project.id,
      'UserName': widget.token.user.userName
    };

    Response response =
        await ApiHelper.post('/api/Ratings/', request, widget.token.token);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }

    _getProject();
    _qualifiable = false;
    _somethingNew = true;
    setState(() {});
  }

  Widget _showParticipation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: const <Widget>[
              Text(
                'Participation: ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          _participable ? _showParticipationMessage() : Container(),
          _participable ? _showParticipationType() : Container(),
          _participable
              ? ElevatedButton(
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Participation  ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: AppColors.white),
                          ),
                          const Icon(Icons.people_alt_rounded)
                        ],
                      )),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      return AppColors.darkblue;
                    }),
                  ),
                  onPressed: () {
                    _participationRequest();
                  },
                )
              : const Text(
                  'You already are participation in this project.',
                  style: TextStyle(fontSize: 16),
                )
        ],
      ),
    );
  }

  void _participationRequest() async {
    if (!_validateFields()) {
      return;
    }

    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Verify that you are connected to the internet.',
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }
    Map<String, dynamic> request = {
      'Id': 0,
      'ParticipationTypeId': _participationTypeId,
      'Message': _message,
      'UserName': _creatorUser(widget.project.participations),
      'ProjectId': widget.project.id,
      'ActiveParticipation': false
    };

    Response response = await ApiHelper.post(
        '/api/Participations/', request, widget.token.token);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }

    //Navigator.pop(context, 'yes');
  }

  Widget _showParticipationMessage() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.multiline,
        minLines: 10,
        maxLines: 50,
        controller: _messageController,
        decoration: InputDecoration(
          hintText: 'Enter a participation message...',
          labelText: 'Participation message',
          errorText: _messageShowError ? _messageError : null,
          suffixIcon: const Icon(Icons.description),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _message = value;
        },
      ),
    );
  }

  Widget _showParticipationType() {
    return Container(
        padding: const EdgeInsets.all(10),
        child: _participationTypes.isEmpty
            ? const Text('Loading participation types...')
            : DropdownButtonFormField(
                items: _getComboParticipationTypes(),
                value: _participationTypeId,
                onChanged: (option) {
                  setState(() {
                    _participationTypeId = option as int;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Select a participation type...',
                  labelText: 'Participation type',
                  errorText: _participationTypeIdShowError
                      ? _participationTypeIdError
                      : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ));
  }

  List<DropdownMenuItem<int>> _getComboParticipationTypes() {
    List<DropdownMenuItem<int>> list = [];

    list.add(const DropdownMenuItem(
      child: Text('Select a participation type...'),
      value: 0,
    ));

    for (var participatinType in _participationTypes) {
      list.add(DropdownMenuItem(
        child: Text(participatinType.description),
        value: participatinType.id,
      ));
    }

    return list;
  }

  Future<void> _participatinTypeTypes() async {
    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Verify that you are connected to the internet.',
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }

    Response response = await ApiHelper.getParticipationTypes(widget.token);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Accept'),
          ]);
      return;
    }

    setState(() {
      _participationTypes = response.result;
    });
  }

  bool _validateFields() {
    bool isValid = true;

    if (_participationTypeId == 0) {
      isValid = false;
      _participationTypeIdShowError = true;
      _participationTypeIdError = 'You must select the type of participation.';
    } else {
      _participationTypeIdShowError = false;
    }

    if (_message.isEmpty) {
      isValid = false;
      _messageShowError = true;
      _messageError = 'You must enter a participation message.';
    } else {
      _messageShowError = false;
    }

    setState(() {});
    return isValid;
  }
}
