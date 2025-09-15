package app.capgo.capacitor.alarm;

import com.getcapacitor.Logger;

public class CapgoAlarm {

    public String echo(String value) {
        Logger.info("Echo", value);
        return value;
    }
}
