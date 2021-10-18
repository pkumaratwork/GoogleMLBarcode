package com.github.rmtmckenzie.qrmobilevision;

interface QrCamera {
    void start(QrReader qrReader) throws QrReader.Exception;
    void stop();
    int getOrientation();
    int getWidth();
    int getHeight();
    boolean supportZoom();
    float getMaxZoom();
    float getMinZoom();
    float getCurrentZoom();
    void setCurrentZoom(float zoomLevel);
}

