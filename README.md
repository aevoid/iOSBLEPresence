iOSBLEPresence
==============

iOS-App for Bluetooth LE Presence Detection to use together with [PiPresenceServer]
(https://github.com/aevoid/PiPresenceServer).

Description
-----------
The iOS-App scans for the peripheral set up by the NodeJS-Server. When found, it tries to connect 
and looks for the writable characteristic. It writes a value to the characteristic every second to
verify its presence. This value is logged by the server and stored to the DB.

Requirements
------------
* min. iPhone4S
* iOS7

References
----------
http://mfg.fhstp.ac.at/development/bluetooth-le-presence-detection-mit-ios-und-raspberry-pi/

Screenshots/Images
------------------
<p><a href="http://mfg.fhstp.ac.at/cms/wp-content/uploads/2014/02/Foto-26.02.14-08-56-34.png"><img src="http://mfg.fhstp.ac.at/cms/wp-content/uploads/2014/02/Foto-26.02.14-08-56-34.png" alt="Screenshot Console PiPresenceServer" width="400"></a></p>
