#ifndef __EVENT_LOOP_DELEGATE_H__
#define __EVENT_LOOP_DELEGATE_H__

class EventLoopDelegate {
public:
    virtual void onMeasureLuxEvent() = 0;
    virtual void onMeasureRGBEvent() = 0;
    virtual void onShutterEvent() = 0;
};

#endif __EVENT_LOOP_DELEGATE_H__
