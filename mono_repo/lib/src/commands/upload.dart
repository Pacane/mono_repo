// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:io/ansi.dart';
import 'package:link_packager/link_packager.dart';
import 'package:path/path.dart' as p;

import '../root_config.dart';
import 'mono_repo_command.dart';

class UploadCommand extends MonoRepoCommand {
  UploadCommand() {
    UploadCommandRunner().argParser.options.forEach((k, v) {
      if (v.name == 'help') {
        return;
      }

      argParser.addOption(v.name,
          abbr: v.abbr, help: v.help, defaultsTo: v.defaultsTo.toString());
    });
  }

  @override
  String get description => 'Upload all DSLinks';

  @override
  String get name => 'upload';

  @override
  Future<void> run() {
    final account = argResults['account'] as String;
    final linkType = argResults['type'] as String;
    return upload(rootConfig(), account, linkType, argResults.rest);
  }
}

Future<void> upload(RootConfig rootConfig, String account, String linkType,
    List<String> args) async {
  final pkgDirs = rootConfig.map((pc) => pc.relativePath).toList();

  print(lightBlue.wrap('Uploading ${pkgDirs.length} package(s)'));

  final links = await File('${rootConfig.rootDirectory}/links').readAsLines();

  for (var config in rootConfig) {
    final dir = config.relativePath;

    if (!links.contains(dir)) {
      continue;
    }

    final workingDir = p.join(rootConfig.rootDirectory, dir);

    final runner = AppCommandRunner();

    final i = await runner
        .run(['upload', '-l', workingDir, '--type', 'dart', '-a', account]);

    final exit = i ?? 1;

    if (exit == 0) {
      print(wrapWith('`$dir`: success!', [styleBold, green]));
    } else {
      print(wrapWith('`$dir`: failed!', [styleBold, red]));
    }
  }
}
