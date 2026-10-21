#!/usr/bin/env python3
import pulsectl
import subprocess

def pause_all():
    print("Pausing all players...")
    subprocess.run(['playerctl', '--all-players', 'pause'])

with pulsectl.Pulse('disconnect-monitor') as pulse:
    # PA delivers events in batches (e.g. sink+card+module remove); keep them all
    events = []

    port_state = {s.index: s.port_active.name if s.port_active else None
                  for s in pulse.sink_list()}

    def callback(ev):
        events.append((ev.t, ev.facility, ev.index))
        raise pulsectl.PulseLoopStop

    pulse.event_mask_set('sink')
    pulse.event_callback_set(callback)

    while True:
        pulse.event_listen(timeout=None)
        batch, events[:] = events[:], []
        paused = False

        for ev_type, ev_facility, ev_index in batch:
            if ev_type == pulsectl.PulseEventTypeEnum.change:
                sink = next((s for s in pulse.sink_list() if s.index == ev_index), None)
                if sink:
                    current_port = sink.port_active.name if sink.port_active else None
                    prev_port = port_state.get(ev_index)
                    port_state[ev_index] = current_port

                    # Wired headphone unplugged: port switched away from headphones
                    if prev_port and 'headphone' in prev_port and current_port and 'headphone' not in current_port:
                        print(f"Wired headphones removed (port: {prev_port} -> {current_port})")
                        paused = True

            elif ev_type == pulsectl.PulseEventTypeEnum.remove:
                port_state.pop(ev_index, None)
                print(f"Sink {ev_index} removed (BT)")
                paused = True

        if paused:
            pause_all()
