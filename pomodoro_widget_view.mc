import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.Time;
import Toybox.Attention;
import Toybox.Application.Storage;
import Toybox.Background;
import Toybox.System;

class pomodoro_widget_input_delegate extends WatchUi.InputDelegate {
  private var _view as pomodoro_widget_view;
    public function initialize(view as pomodoro_widget_view) {
        InputDelegate.initialize();
        _view = view;
    }

    function onTap(clickEvent) {
      var coords = clickEvent.getCoordinates();
      _view.tap(coords[1]);
      return true;
    }

}


class pomodoro_widget_view extends WatchUi.View {
  private var state; // 0: off, 1:on,
  private var dc;
  private var _ticking_timer; // updates countdown
  private var _duration;
  private var stop_time;
  private var alarm;
  var dc_height;
  var dc_width;
  private var duration_short=25;
  private var duration_long=55;

    function initialize() {
      System.println("view initialize");
      _ticking_timer=new Toybox.Timer.Timer();
      View.initialize();
  }

    public function onTick(){
      WatchUi.requestUpdate();
    }

    function loadVars() {      // if-else below loads vars from bg
      state=Storage.getValue("state");
      if (state==null) {    // on app start
	state=0;
	alarm=false;
	Storage.setValue("state",state);
	Storage.setValue("_duration",_duration);
	Storage.setValue("alarm",alarm);
      } else { // on app show from background
	alarm=Storage.getValue("alarm");
	_duration=Storage.getValue("_duration");
	stop_time = new Time.Moment(Storage.getValue("stop_time"));
      }
    }

    function saveVars() {
      Storage.setValue("state",state);
      Storage.setValue("_duration",_duration);
      if (stop_time==null) {
      } else {
      Storage.setValue("stop_time",stop_time.value());
      }
      Storage.setValue("alarm",alarm);
    }
    
    function onUpdate(dc_in as Dc) {
      loadVars();    
      if (alarm){ // if alarm, transition state
	onTimerExpired();
      }
      dc=dc_in;
      dc_height=dc.getHeight();
      dc_width=dc.getWidth();
      dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
      dc.clear();
      switch(state) {
      case 0:
	drawOffState();
	break;
      case 1:
	drawOnState();
	_ticking_timer.start(self.method(:onTick),1000,true);
	break;
      case 2:
	drawOnState();
	_ticking_timer.start(self.method(:onTick),1000,true);
	break;
      }
      saveVars();
    }
    
    function drawOffState() {  // loadVars/saveVars not necessary - only called from onUpdate
      dc.drawText(dc_width/2,dc_height/4-20, Graphics.FONT_MEDIUM,"Start "+duration_short.format("%d"),Graphics.TEXT_JUSTIFY_CENTER);
      dc.drawText(dc_width/2,3*dc_height/4-20, Graphics.FONT_MEDIUM,"Start "+duration_long.format("%d"),Graphics.TEXT_JUSTIFY_CENTER);
      dc.drawLine(0,dc_height/2,dc_width,dc_height/2);
    }

    function stop() {
      state=0;
      _ticking_timer.stop();
      Storage.clearValues();
      Background.deleteTemporalEvent();
    }
    
    function startFocus() { // loadVars/saveVars not necessary - only called from onUpdate via onTimerExpired
      state=1;
      stop_time=Time.now().add(new Time.Duration(_duration*60));
      Background.registerForTemporalEvent(stop_time);
    }
    function startBreak() { // loadVars/saveVars not necessary - only called from onUpdate via onTimerExpired
      state=2;
      stop_time=Time.now().add(new Time.Duration(5*60));
      Background.registerForTemporalEvent(stop_time);
    }
    
    function onTimerExpired(){  // loadVars/saveVars not necessary - only called from onUpdate
      Background.deleteTemporalEvent();
      var vibe=[new Attention.VibeProfile(25, 500)];
      Attention.vibrate(vibe);
      if (state==1) {
	startBreak();
      } else if (state==2) {
	startFocus();
      }
      alarm=false;
    }
  
    
    function drawOnState() { // loadVars/saveVars not necessary - only called from onUpdate
      if (state==1) {
	dc.drawText(dc_width/2,dc_height/4-20, Graphics.FONT_MEDIUM,"Focus",Graphics.TEXT_JUSTIFY_CENTER);
      } else if (state==2) {
	dc.drawText(dc_width/2,dc_height/4-20, Graphics.FONT_MEDIUM,"Break",Graphics.TEXT_JUSTIFY_CENTER);

      }
dc.drawText(dc_width/2,dc_height/2-20,Graphics.FONT_MEDIUM,toMS(stop_time.subtract(Time.now()).value()),Graphics.TEXT_JUSTIFY_CENTER);
      dc.drawText(dc_width/2,3*dc_height/4-20,Graphics.FONT_MEDIUM,"Stop",Graphics.TEXT_JUSTIFY_CENTER);
    }
  
    function toMS(secs) {
      var min = secs/60;
      var sec = secs%60;
      return min.format("%02d")+":"+sec.format("%02d");
    }
    
    function tap(y as Toybox.Lang.Number){ 
      if (state==0) {
	if (y>dc_height/2) { // start 55 min (duration_long) button
	  _duration=duration_long;
	  startFocus();
	}
	else { // start 25 min (duration_short) button
	  _duration=duration_short;
	  startFocus();
	}
      } else {
	if (y>2*dc_height/3){ // stop button
	  stop();
	}
      }
      saveVars();
      WatchUi.requestUpdate(); 
    }
    

}


