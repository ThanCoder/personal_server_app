import 'package:flutter/material.dart';
import 'package:person_server/app/models/index.dart';

ValueNotifier<bool> isServerRunningNotifier = ValueNotifier(false);
ValueNotifier<List<ServerFileModel>> serverSendListNotifier = ValueNotifier([]);

ValueNotifier<String> serverHostAddressNotifier = ValueNotifier('');
ValueNotifier<String> serverSendFolderPathNotifier = ValueNotifier('');
//client
ValueNotifier<String> clientHostAddressNotifier = ValueNotifier('');
