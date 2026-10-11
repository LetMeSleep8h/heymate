import React from 'react';
import {CanvasImage, Interactive, interpolate, staticFile, useCurrentFrame, useVideoConfig} from 'remotion';
import {TEACHING, TeachingFrame, TeachingTitle} from './TeachingFrame';

export const TeachingMates: React.FC = () => {
  const frame = useCurrentFrame();
  const {width, height, fps} = useVideoConfig();
  const vertical = height > width;
  return (
    <TeachingFrame>
      <div style={{position: 'absolute', top: vertical ? 310 : 220, left: 88, right: 88}}>
        <TeachingTitle style={{fontSize: vertical ? 109 : 124}}>A familiar mate.{'\n'}A job of their own.</TeachingTitle>
        <div style={{fontSize: 46, marginTop: 34, color: TEACHING.muted}}>Give each helper a name and a role.</div>
      </div>
      <div style={{position: 'absolute', top: vertical ? 880 : 610, left: 88, right: 88, display: 'flex', flexDirection: vertical ? 'column' : 'row', gap: 32}}>
        <Interactive.Div name="Tutor example" style={{flex: 1, display: 'flex', alignItems: 'center', gap: 30, borderTop: `2px solid ${TEACHING.line}`, padding: '36px 0', opacity: interpolate(frame, [0.6 * fps, 1 * fps], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'})}}>
          <CanvasImage src={staticFile('faces/amber.jpg')} premountFor={fps} style={{width: 142, height: 142, borderRadius: 40, flexShrink: 0}} />
          <div><div style={{fontSize: 62, fontWeight: 600}}>Mira</div><div style={{fontSize: 37, color: TEACHING.muted}}>Your patient design tutor</div></div>
        </Interactive.Div>
        <Interactive.Div name="Project partner example" style={{flex: 1, display: 'flex', alignItems: 'center', gap: 30, borderTop: `2px solid ${TEACHING.line}`, padding: '36px 0', opacity: interpolate(frame, [1.4 * fps, 1.8 * fps], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'})}}>
          <CanvasImage src={staticFile('faces/robot.jpg')} premountFor={fps} style={{width: 142, height: 142, borderRadius: 40, flexShrink: 0}} />
          <div><div style={{fontSize: 62, fontWeight: 600}}>Bolt</div><div style={{fontSize: 37, color: TEACHING.muted}}>Your practical code partner</div></div>
        </Interactive.Div>
      </div>
    </TeachingFrame>
  );
};
