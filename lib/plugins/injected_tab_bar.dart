import 'package:parabeac_core/controllers/main_info.dart';
import 'package:parabeac_core/generation/generators/pb_flutter_generator.dart';
import 'package:parabeac_core/generation/generators/pb_generator.dart';
import 'package:parabeac_core/generation/generators/pb_widget_manager.dart';
import 'package:parabeac_core/input/entities/layers/abstract_layer.dart';
import 'package:parabeac_core/plugins/injected_tab.dart';
import 'package:parabeac_core/interpret_and_optimize/entities/interfaces/pb_inherited_intermediate.dart';
import 'package:parabeac_core/interpret_and_optimize/entities/interfaces/pb_injected_intermediate.dart';
import 'package:parabeac_core/generation/generators/plugins/pb_plugin_node.dart';
import 'package:parabeac_core/interpret_and_optimize/entities/subclasses/pb_intermediate_node.dart';
import 'package:parabeac_core/interpret_and_optimize/helpers/pb_context.dart';
import 'package:parabeac_core/interpret_and_optimize/value_objects/point.dart';

import 'package:json_annotation/json_annotation.dart';


class InjectedTabBar extends PBNakedPluginNode
    implements PBInjectedIntermediate {
  final String UUID;
  PBContext currentContext;
  String semanticName = '.*tabbar';
  List<Tab> tabs = [];

  String widgetType = 'APPBAR';

  InjectedTabBar(
    Point topLeftCorner,
    Point bottomRightCorner,
    this.UUID, {
    this.currentContext,
  }) : super(topLeftCorner, bottomRightCorner, currentContext) {
    generator = PBTabBarGenerator(currentContext.generationManager);
  }

  @override
  void addChild(PBIntermediateNode node) {
    if (node is PBInheritedIntermediate) {
      if ((node as PBInheritedIntermediate)
          .originalRef
          .name
          .contains('.*tab')) {
        assert(node is! Tab, 'I wrote something wrong here: IvanH');
        tabs.add(node);
      }
    }

    if (node is Tab) {
      tabs.add(node);
    }
  }

  @override
  List<PBIntermediateNode> layoutInstruction(List<PBIntermediateNode> layer) {}

  @override
  void alignChild() {}

  @override
  PBNakedPluginNode generatePluginNode(
      Point topLeftCorner, Point bottomRightCorner, SketchNode originalRef) {
    return InjectedTabBar(topLeftCorner, bottomRightCorner, UUID,
        currentContext: currentContext);
  }

  @override
  void extractInformation(SketchNode incomingNode) {
    // TODO: implement extractInformation
  }
}
class PBTabBarGenerator extends PBGenerator {
  final PBGenerationManager manager;
  PBTabBarGenerator(this.manager) : super('TABBAR');

  @override
  String generate(PBIntermediateNode source) {
    if (source is InjectedTabBar) {
      var buffer = StringBuffer();
      buffer.write('BottomNavigationBar(');
      buffer.write('type: BottomNavigationBarType.fixed,');
      try {
        buffer.write('items:[');
        for (var i = 0; i < source.tabs.length; i++) {
          buffer.write('BottomNavigationBarItem(');
          var res =
              manager.generate(source.tabs[i].child, type: BUILDER_TYPE.BODY);
          buffer.write('icon: $res,');
          buffer.write('title: Text(""),');
          buffer.write('),');
        }
      } catch (e, stackTrace) {
        MainInfo().sentry.captureException(
              exception: e,
              stackTrace: stackTrace,
            );
        buffer.write('),');
      }
      buffer.write('],');
      buffer.write(')');
      return buffer.toString();
    }
  }
}
