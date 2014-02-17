iOSBLEPresence
==============

iOS-App for Bluetooth LE Presence Detection to use together with [PiPresenceServer]
(https://github.com/aevoid/PiPresenceServer).

Description
-----------
The iOS-App scans for the peripheral set up by the NodeJS-Server. When found, it tries to connect 
and looks for the writable characteristic. It writes a value to the characteristic every second to
verify its presence. This value is logged by the server and stored to the DB.

Dependencies
------------
* min. iPhone4S
* iOS7

References
----------
http://mfg.fhstp.ac.at/development/bluetooth-le-presence-detection-mit-ios-und-raspberry-pi/
