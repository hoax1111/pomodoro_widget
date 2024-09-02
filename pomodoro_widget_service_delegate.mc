import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application.Storage;

(:background)
class pomodoro_widget_service_delegate extends System.ServiceDelegate {

  public function initialize(){
      ServiceDelegate.initialize();
    }

    function onTemporalEvent(){
      System.println("onTemporalEvent");
      Storage.setValue("alarm",true);
      var state=Storage.getValue("state");
      if (state==1){
        Background.requestApplicationWake("Start break?");
      } else if(state==2) {
        Background.requestApplicationWake("Start focus?");
      }
      Background.exit(1);
    }
}
