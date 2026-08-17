# Capture and smart selection

![Smart selection example](../assets/sc2.png)

During a capture, EasySnipping first helps you find window and control boundaries. When automatic detection is not a good fit, you can always drag a free-form selection.

## Detect windows and controls

1. Press `Ctrl+Shift+S` to start a capture.
2. Move the pointer over a window or control and wait for a candidate border.
3. Click the candidate region to confirm it.

Smart selection combines window, child-control, and accessibility information. Elevated, custom-drawn, or specially rendered windows may not expose an exact control boundary. In that case, EasySnipping falls back to a window candidate or keeps free-form selection available.

## Free-form selection

Drag with the left mouse button on the overlay to create a free-form region. It is useful when you want to:

- Capture only part of a window.
- Select an area spanning several controls.
- Continue when automatic detection does not find a suitable candidate.

Multiple monitors and the virtual desktop coordinate space are supported. After confirming a region, drag inside it to move it or use the resize handles to adjust its bounds.

## Cancel or start over

- Press `Esc` or the right mouse button to cancel.
- Click outside a confirmed selection to choose another region.
- When the toolbar is close to a screen edge, it moves above the selection or into another available position.

Next: [Annotation tools](Annotation.md).
