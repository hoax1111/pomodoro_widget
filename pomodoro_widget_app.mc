
import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class pomodoro_widget_app extends Application.AppBase {
    //! Constructor
    public function initialize() {
        AppBase.initialize();
    }

    //! Handle app startup
    //! @param state Startup arguments
    // stub is sufficient for widgets
    public function onStart(state as Dictionary?) as Void {
    }

    //! Handle app shutdown
    //! @param state Shutdown arguments
    // stub is sufficient for widgets
    public function onStop(state as Dictionary?) as Void {
    }

    //! Return the initial views for the app
    //! @return Array Pair [View, InputDelegate]
    public function getInitialView() {
      var view = new pomodoro_widget_view();
      return [view, new pomodoro_widget_input_delegate(view)];
    }

    public function onBackgroundData(data) {
      Storage.setValue("alarm",true);
      WatchUi.requestUpdate();
    }

    public function getServiceDelegate(){
      return [new pomodoro_widget_service_delegate()];
    }
    public function onAppUpdate() {
    }
}
