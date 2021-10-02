###### tags: `BW16`,`MAC`

[![hackmd-github-sync-badge](https://hackmd.io/S_XToTfoTbmHgLuTzMu4PA/badge)](https://hackmd.io/S_XToTfoTbmHgLuTzMu4PA)

# 背景檢查Zoom狀態並即時觸發Http指示燈

* [Github](https://github.com/Chihhao/BW16_MAX7219_HTTP)
* 暫時僅支援mac

![](https://i.imgur.com/FXoSU7K.jpg)
![](https://i.imgur.com/2De1XdK.jpg)
![](https://i.imgur.com/veVJFFS.jpg)
![](https://i.imgur.com/Nz1f8Ed.jpg)
![](https://i.imgur.com/QphpZY7.jpg)
![](https://i.imgur.com/AJ1IVUj.jpg)
![](https://i.imgur.com/XBXXLcT.jpg)
![](https://i.imgur.com/fx3KrTp.jpg)
![](https://i.imgur.com/CFNu5ML.jpg)
![](https://i.imgur.com/qhCnPra.jpg)
![](https://i.imgur.com/JOStjbx.jpg)
![](https://i.imgur.com/26OX04w.jpg)
![](https://i.imgur.com/ATuyfCt.jpg)

# BW16 Http指示燈
* [BW16](https://www.amebaiot.com/zh/amebad-bw16-arduino-getting-started/)
* 經典 Http Server 範例
* [U8g2 Library](https://www.arduino.cc/reference/en/libraries/u8g2/)
* [外殼](https://www.thingiverse.com/thing:3444779) 
* 接線
```
VCC - 5V
GND - GND
DIN - PA13
CS  - PA15
CLK - PA12
```
* Arduino Code

```cpp=
#include <U8g2lib.h>
U8G2_MAX7219_32X8_F_4W_SW_SPI u8g2(
  U8G2_R0, 
  /* clock=*/ PA12, 
  /* data=*/ PA13, 
  /* cs=*/ PA15, 
  /* dc=*/ U8X8_PIN_NONE, 
  /* reset=*/ U8X8_PIN_NONE);

#include <WiFi.h>
char ssid[] = "******";        //  your network SSID (name)
char pass[] = "******";           // your network password
int status = WL_IDLE_STATUS;
WiFiServer server(80);


bool _global_MIC = false;
bool _global_AIR = false;
bool _global_CAM = false;

void setup(void) {
  u8g2.begin();
  u8g2.setContrast(1*10); // 0-255

  Serial.begin(115200);         // initialize serial communication
      
}

void loop(void) {
  checkWifi();
  checkClient();
  
  u8g2.clearBuffer();          // clear the internal memory

  // 畫麥克風圖示
  if(_global_MIC){  
    u8g2.setFont(u8g2_font_open_iconic_play_1x_t); // choose a suitable font
    u8g2.drawGlyph(0,8,76);     // write something to the internal memory
    u8g2.drawPixel(3,6);
  }

  // 畫AIR
  if(_global_AIR){  
    u8g2.setFont(u8g2_font_u8glib_4_tf); // choose a suitable font
    u8g2.drawStr(10,6,"AIR");     // write something to the internal memory
    u8g2.setDrawColor(0);
    u8g2.drawPixel(18,3);
    u8g2.drawPixel(19,3);
    u8g2.drawPixel(20,2);
    u8g2.setDrawColor(1);
    u8g2.drawPixel(18,4); 
    // 畫分隔線
    u8g2.drawLine(8,1,8,6);
    u8g2.drawLine(22,1,22,6);   
  }
  else{
//    u8g2.setFont(u8g2_font_u8glib_4_tf); // choose a suitable font
//    u8g2.drawStr(10,6,"OFF");     // write something to the internal memory
  }

  // 畫攝影機圖示
  if(_global_CAM){  
    u8g2.drawLine(24,2,28,2); u8g2.drawPixel(30,2);
    u8g2.drawLine(24,3,30,3);
    u8g2.drawLine(24,4,30,4);
    u8g2.drawLine(24,5,28,5); u8g2.drawPixel(30,5);
  }

  u8g2.sendBuffer();          // transfer internal memory to the display
  delay(1000);  
}

void checkWifi(){
    if(status == WL_CONNECTED) return;
    
    showConnecting();
    delay(1000);  

    Serial.print("Attempting to connect to Network named: ");
    Serial.println(ssid);                   // print the network name (SSID);
    status = WiFi.begin(ssid, pass);

    int iAgain = 0;
    while (status != WL_CONNECTED) {
        delay(1000);
        if(++iAgain>5) {
          status = WiFi.begin(ssid, pass);
        }
    }
    
    server.begin();                           // start the web server on port 80
    printWifiStatus();                        // you're connected now, so print out the status
    
    showReady();
    delay(1000);  
}

void printWifiStatus() {
    // print the SSID of the network you're attached to:
    Serial.print("SSID: ");
    Serial.println(WiFi.SSID());

    // print your WiFi shield's IP address:
    IPAddress ip = WiFi.localIP();
    Serial.print("IP Address: ");
    Serial.println(ip);

    // print the received signal strength:
    long rssi = WiFi.RSSI();
    Serial.print("signal strength (RSSI):");
    Serial.print(rssi);
    Serial.println(" dBm");
    // print where to go in a browser:
    Serial.print("To see this page in action, open a browser to http://");
    Serial.println(ip);
}

void checkClient(){
  WiFiClient client = server.available();     // listen for incoming clients

    if (client) {                               // if you get a client,
        Serial.println("new client");           // print a message out the serial port
        String currentLine = "";                // make a String to hold incoming data from the client
        while (client.connected()) {            // loop while the client's connected
            if (client.available()) {           // if there's bytes to read from the client,
                char c = client.read();         // read a byte, then
                Serial.write(c);                // print it out the serial monitor
                if (c == '\n') {                // if the byte is a newline character

                    // if the current line is blank, you got two newline characters in a row.
                    // that's the end of the client HTTP request, so send a response:
                    if (currentLine.length() == 0) {
                        // HTTP headers always start with a response code (e.g. HTTP/1.1 200 OK)
                        // and a content-type so the client knows what's coming, then a blank line:
                        client.println("HTTP/1.1 200 OK");
                        client.println("Content-type:text/html");
                        client.println();

                        // the content of the HTTP response follows the header:
//                        client.print("Click <a href=\"/MIC_ON\">here</a> MIC_ON<br>");
//                        client.print("Click <a href=\"/MIC_OFF\">here</a> MIC_OFF<br>");
//                        client.print("Click <a href=\"/AIR_ON\">here</a> AIR_ON<br>");
//                        client.print("Click <a href=\"/AIR_OFF\">here</a> AIR_OFF<br>");
//                        client.print("Click <a href=\"/CAM_ON\">here</a> CAM_ON<br>");
//                        client.print("Click <a href=\"/CAM_OFF\">here</a> CAM_OFF<br>");
                        
                        // The HTTP response ends with another blank line:
//                        client.println();
                        // break out of the while loop:
                        break;
                    } else {    // if you got a newline, then clear currentLine:
                        currentLine = "";
                    }
                } else if (c != '\r') {  // if you got anything else but a carriage return character,
                    currentLine += c;      // add it to the end of the currentLine
                }

                
                if (currentLine.endsWith("GET /MIC_ON")) {
                    _global_MIC = true;
                }
                if (currentLine.endsWith("GET /MIC_OFF")) {
                    _global_MIC = false;
                }
                if (currentLine.endsWith("GET /AIR_ON")) {
                    _global_AIR = true;
                }
                if (currentLine.endsWith("GET /AIR_OFF")) {
                    _global_AIR = false;
                }
                if (currentLine.endsWith("GET /CAM_ON")) {
                    _global_CAM = true;
                }
                if (currentLine.endsWith("GET /CAM_OFF")) {
                    _global_CAM = false;
                }
               
            }
        }
        // close the connection:
        client.stop();
        Serial.println("client disonnected");
    }
}

void showConnecting(){
  u8g2.clearBuffer();          // clear the internal memory
  u8g2.setFont(u8g2_font_u8glib_4_tf); // choose a suitable font
  u8g2.drawStr(2,6,"WIFI......");     // write something to the internal memory
  u8g2.sendBuffer();          // transfer internal memory to the display
}

void showReady(){
  u8g2.clearBuffer();          // clear the internal memory
  u8g2.setFont(u8g2_font_u8glib_4_tf); // choose a suitable font
  u8g2.drawStr(2,6,"READY!");     // write something to the internal memory
  
  u8g2.setDrawColor(0);
  u8g2.drawPixel(3,3);
  u8g2.drawPixel(4,3);
  u8g2.drawPixel(5,2);
  u8g2.setDrawColor(1);
  u8g2.drawPixel(3,4); 
  
  u8g2.sendBuffer();          // transfer internal memory to the display
}
```

# AppleScript
* zoomstatus.applescript
```
#!/usr/bin/osascript
global AIR_ENABLED
global MIC_ENABLED
global CAM_ENABLED

set AIR_ENABLED to false
set MIC_ENABLED to false
set CAM_ENABLED to false

tell application "System Events"
    repeat
        if exists (process "zoom.us") then
            
            tell application process "zoom.us"
                try
                    if exists (menu "會議" of menu bar 1) then
                        
                        my AIR_SWITCH(true)
                        if exists (menu item "音訊靜音" of menu "會議" of menu bar 1) then
                            my MIC_SWITCH(true)
                        else
                            my MIC_SWITCH(false)
                        end if
                        
                        if exists (menu item "停止視訊" of menu "會議" of menu bar 1) then
                            my CAM_SWITCH(true)
                        else
                            my CAM_SWITCH(false)
                        end if
                        
                    else
                        
                        my AIR_SWITCH(false)
                        my MIC_SWITCH(false)
                        my CAM_SWITCH(false)
                        
                    end if
                end try
            end tell
            
        else
            my AIR_SWITCH(false)
            
        end if       
        
        delay 1
    end repeat
end tell

on MIC_SWITCH(status)
    if not MIC_ENABLED = status then
        set MIC_ENABLED to status
        if MIC_ENABLED = true then
            do shell script "curl http://10.0.4.30/MIC_ON --connect-timeout 2"
        else
            do shell script "curl http://10.0.4.30/MIC_OFF --connect-timeout 2"
        end if
    end if
end MIC_SWITCH

on CAM_SWITCH(status)
    if not CAM_ENABLED = status then
        set CAM_ENABLED to status
        if CAM_ENABLED = true then
            do shell script "curl http://10.0.4.30/CAM_ON --connect-timeout 2"
        else
            do shell script "curl http://10.0.4.30/CAM_OFF --connect-timeout 2"
        end if
    end if
end CAM_SWITCH

on AIR_SWITCH(status)
    if not AIR_ENABLED = status then
        set AIR_ENABLED to status
        if AIR_ENABLED = true then
            do shell script "curl http://10.0.4.30/AIR_ON --connect-timeout 2"
        else
            do shell script "curl http://10.0.4.30/AIR_OFF --connect-timeout 2"
        end if
    end if
end AIR_SWITCH

```

# 讓AppleScript在背景執行
* Create 一個 Job (.plist檔案)
* 使用 launchctl 啟動 Job

## Create a .plist file
* 在這裡產生新檔案 ```~/Library/LaunchAgents/```
* 例如取名```ZoomStatus.plist```
* 檔案內容如下，注意 ==job名稱== 與 ==plist的絕對路徑==
```xml=
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>zoom-status.job</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/osascript</string>
        <string>/Users/chihhaolai/Documents/AppleScript/zoomstatus.applescript</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
```
![](https://i.imgur.com/WderYWJ.png)

* 加入Job
```
launchctl load -w ~/Library/LaunchAgents/ZoomStatus.plist
```
* 啟動 Job
```
launchctl start zoom-status.job
```
* 停止 Job
```
launchctl stop zoom-status.job
```
* 移除Job
```
launchctl unload -w ~/Library/LaunchAgents/ZoomStatus.plist
```
