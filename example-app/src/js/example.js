import { CapgoAlarm } from '@capgo/capacitor-alarm';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    CapgoAlarm.echo({ value: inputValue })
}
