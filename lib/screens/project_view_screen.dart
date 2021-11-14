import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:madeupu_app/components/loader_component.dart';
import 'package:madeupu_app/helpers/app_colors.dart';
import 'package:madeupu_app/models/project.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ProjectViewScreen extends StatefulWidget {
  final Project project;
  // ignore: use_key_in_widget_constructors
  const ProjectViewScreen({required this.project});

  @override
  _ProjectViewScreenState createState() => _ProjectViewScreenState();
}

class _ProjectViewScreenState extends State<ProjectViewScreen> {
  final bool _showLoader = false;
  int _current = 0;
  final CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.project.id == 0 ? 'New project' : widget.project.name),
      ),
      body: Stack(
        children: [
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
                _showRating(),
                _showProjectCreatorName(),
                _showCreatorPhoneNumber(),
                _showCreatorWhatsApp(),
                _showProjectDescription(),
                _showProjectVideo(),
                _showPhotosCarousel(),
                _showComments(),
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
    );
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
                    'Visit official website',
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

  _launchURL(String url) async {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Text(
            'Rating: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            'Media ${widget.project.averageRating}, total ${widget.project.ratingsNumber}',
            style: const TextStyle(fontSize: 20),
          )
        ],
      ),
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
      text: 'Hola te escribo del taller.',
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
          )
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
          SizedBox(
            height: 300,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: widget.project.comments.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 5, top: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: index % 2 == 0
                              ? AppColors.darkblue
                              : AppColors.blue,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              _showCommentUserPhoto(widget
                                  .project.comments[index].user.imageFullPath),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                widget.project.comments[index].user.fullName,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Flexible(
                            child: Text(
                              widget.project.comments[index].message,
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
        ],
      ),
    );
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
}
