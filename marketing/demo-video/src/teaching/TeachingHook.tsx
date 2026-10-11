import React from 'react';
import {Interactive, interpolate, useCurrentFrame, useVideoConfig} from 'remotion';
import {TEACHING, TeachingFrame, TeachingTitle} from './TeachingFrame';

export const TeachingHook: React.FC = () => {
  const frame = useCurrentFrame();
  const {width, height, fps} = useVideoConfig();
  const vertical = height > width;
  return (
    <TeachingFrame>
      <div style={{position: 'absolute', left: 88, right: 88, top: vertical ? 350 : 230}}>
        <div style={{fontSize: 30, color: TEACHING.blue, fontWeight: 600, marginBottom: 32}}>A NEW WAY TO ASK FOR HELP</div>
        <TeachingTitle style={{fontSize: vertical ? 126 : 148}}>Learn it.{'\n'}Then keep it.</TeachingTitle>
        <Interactive.Div name="Benefit" style={{fontSize: vertical ? 48 : 50, lineHeight: 1.35, marginTop: 40, maxWidth: vertical ? 850 : 1180, color: TEACHING.muted, opacity: interpolate(frame, [0.6 * fps, 1.1 * fps], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'})}}>
          A Mac companion that helps you{'\n'}learn the app in front of you.
        </Interactive.Div>
      </div>
      <Interactive.Div name="Example question" style={{position: 'absolute', left: 88, right: 88, top: vertical ? 1130 : 790, borderLeft: `6px solid ${TEACHING.blue}`, padding: '22px 32px', fontSize: vertical ? 44 : 46, lineHeight: 1.35, color: TEACHING.blue, opacity: interpolate(frame, [1.5 * fps, 2 * fps], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'})}}>
        “Show me how to remove this background.”
      </Interactive.Div>
    </TeachingFrame>
  );
};
