void setupKinect() {
  //frameRate(30);
  //size(640, 480);

  kinect = new SimpleOpenNI(this);
  if (kinect.isInit() == false) {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!");
    exit();
    return;
  }
  // enable depthMap generation 
  kinect.enableDepth();

  // disable mirror
  kinect.setMirror(true);

  // enable hands + gesture generation
  //kinect.enableGesture();
  kinect.enableHand();
  kinect.startGesture(SimpleOpenNI.GESTURE_HAND_RAISE);
  kinect.startGesture(SimpleOpenNI.GESTURE_WAVE);
  kinect.startGesture(SimpleOpenNI.GESTURE_CLICK);

  // set how smooth the hand capturing should be
  //kinect.setSmoothingHands(.5);
  cursor = new PVector(0, 0);
}

void drawKinect() {
  boolean infinite = true;
  while (infinite) {
    infinite = true; // Debug purposes
    // update the cam
    delay(33);
    kinect.update();
    // image(kinect.depthImage(), 0, 0); // Uncomment to kinect depth image
    // Iterate the tracked hands
    if (handPathList.size() > 0) {
      Iterator itr = handPathList.entrySet().iterator();
      int i = 1;
      while (i == 1) { // Currently limited to one hand
        Map.Entry mapEntry = (Map.Entry) itr.next();
        int handId = (Integer) mapEntry.getKey();
        ArrayList < PVector > vecList = (ArrayList < PVector > ) mapEntry.getValue();
        PVector p;
        PVector p2d = new PVector();
        /* // Uncomment to draw tails for hands
      stroke(userClr[(handId - 1) % userClr.length]);
      noFill();
      strokeWeight(1);
      Iterator itrVec = vecList.iterator();
      beginShape();
      while (itrVec.hasNext()) {
        p = (PVector) itrVec.next();
        kinect.convertRealWorldToProjective(p, p2d);
        vertex(p2d.x, p2d.y);
      }
      endShape();

      stroke(userClr[(handId - 1) % userClr.length]);
      strokeWeight(4);
      */
        p = vecList.get(0);
        kinect.convertRealWorldToProjective(p, p2d);
        cursor = p2d;
        cursor.x = (p2d.x / 640) * width; // Scale cursor position to match resolution
        cursor.y = (p2d.y / 480) * height;
        i++;
      }
    }
    if (handPathList.size() == 2) { // Zoom in the case of two hands
      PVector h1 = new PVector(0, 0);
      PVector h1_2d = new PVector(0, 0);
      PVector h2 = new PVector(0, 0);
      PVector h2_2d = new PVector(0, 0);

      Iterator itr = handPathList.entrySet().iterator();
      while (itr.hasNext()) {
        Map.Entry mapEntry = (Map.Entry) itr.next();
        ArrayList < PVector > vecList = (ArrayList < PVector > ) mapEntry.getValue();
        h1 = vecList.get(0);
        kinect.convertRealWorldToProjective(h1, h1_2d);
        mapEntry = (Map.Entry) itr.next();
        vecList = (ArrayList < PVector > ) mapEntry.getValue();
        h2 = vecList.get(0);
        kinect.convertRealWorldToProjective(h2, h2_2d);
      }
      //int zoomMax = 1500;
      int zoomMin = 100;
      if (zoomY > zoomMin) {
        zoomY += 25 * ((h1.x - h2.x - 500) / 200);
        zoomX += 25 * zoomYX * ((h1.x - h2.x - 500) / 200);
        // zoomMax needs testing
        /*if (zoomY > zoomMax || zoomX > zoomMax) {
        zoomY = zoomMax;
        zoomX = zoomMax* zoomYX;
      }
      else if (zoomY < zoomMax || zoomX < zoomMax) {
        zoomY = zoomMin;
        zoomX = zoomMin* zoomYX;
      }*/
      } else {
        zoomY += 100;
        zoomX += 100 * zoomYX;
      }
    }
  }
}

//-----------------------------------------------------------------
// hand events

void onNewHand(SimpleOpenNI curkinect, int handId, PVector pos) {
  println("onNewHand - handId: " + handId + ", pos: " + pos);
  ArrayList < PVector > vecList = new ArrayList < PVector > ();
  vecList.add(pos);
  handPathList.put(handId, vecList);
}

void onTrackedHand(SimpleOpenNI curkinect, int handId, PVector pos) {
  //println("onTrackedHand - handId: " + handId + ", pos: " + pos );
  ArrayList < PVector > vecList = handPathList.get(handId);
  if (vecList != null) {
    vecList.add(0, pos);
    if (vecList.size() >= handVecListSize)
    // remove the last point 
    vecList.remove(vecList.size() - 1);
  }
}

void onLostHand(SimpleOpenNI curkinect, int handId) {
  println("LOST");
  handPathList.remove(handId);
  if (handPathList.size() < 1) {
    reset();
  }
}

// -----------------------------------------------------------------
// gesture events

void onCompletedGesture(SimpleOpenNI curkinect, int gestureType, PVector pos) {
  //println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);
  if (gestureType == 0) {
    println("WAVE");
    //int handId = kinect.startTrackingHand(pos);
    if (!select) select = true;
    else {
      select = false;
    }
  } else if (gestureType == 1) {
    println("CLICK");
    //int handId = kinect.startTrackingHand(pos);
    firstPressed = true;
    if (!drag) drag = true;
    else {
      drag = false;
      origoX = x;
      origoY = y;
    }
  } else if (gestureType == 2) {
    println("RAISE_HAND");
    if (!tracking) {
      int handId = kinect.startTrackingHand(pos);
      tracking = true;
    } else if (true) {
      println("NumHands:");
      println(handPathList.size());
      int handId = kinect.startTrackingHand(pos);
      //tracking = true;
    }
  }
}

// -----------------------------------------------------------------
// Keyboard event
/*void keyPressed()
{
  switch(key)
  {
  case ' ':
    kinect.setMirror(!kinect.mirror());
    break;
  case '1':
    kinect.setMirror(true);
    break;
  case '2':
    kinect.setMirror(false);
    break;
  }
}
*/

void reset() {
  drag = false;
  select = false;
  tracking = false;
  select = false;
}
