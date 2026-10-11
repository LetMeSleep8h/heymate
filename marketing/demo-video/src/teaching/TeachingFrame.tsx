import React from 'react';
import {AbsoluteFill, CanvasImage, Interactive, interpolate, staticFile, useCurrentFrame, useVideoConfig} from 'remotion';
import {FONTS} from '../config';

export const TEACHING = {
  ink: '#171A20',
  paper: '#F3F1EB',
  blue: '#2869E8',
  muted: '#656A72',
  line: '#D7D7D2',
  mint: '#DFF2C9',
};

export const TeachingFrame: React.FC<{
  children: React.ReactNode;
  dark?: boolean;
  style?: React.CSSProperties;
}> = ({children, dark = false, style}) => {
  const {width, height, fps} = useVideoConfig();
  const vertical = height > width;
  return (
    <AbsoluteFill style={{background: dark ? TEACHING.ink : TEACHING.paper, color: dark ? TEACHING.paper : TEACHING.ink, fontFamily: FONTS.ui, ...style}}>
      <div style={{position: 'absolute', top: vertical ? 104 : 62, left: 88, right: 88, display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
        <div style={{display: 'flex', alignItems: 'center', gap: 18, fontSize: 36, fontWeight: 600}}>
          <CanvasImage src={staticFile('icon.png')} premountFor={fps} style={{width: 52, height: 52, borderRadius: 13}} />
          HeyMate
        </div>
        <div style={{fontSize: vertical ? 23 : 24, letterSpacing: 2, fontWeight: 600, opacity: 0.72}}>ILLUSTRATED CONCEPT</div>
      </div>
      {children}
      <div style={{position: 'absolute', bottom: vertical ? 104 : 60, left: 88, right: 88, borderTop: `1px solid ${dark ? '#45494F' : TEACHING.line}`, paddingTop: 22, fontSize: vertical ? 25 : 27, opacity: 0.72}}>
        Workflow illustration · not a screen recording
      </div>
    </AbsoluteFill>
  );
};

export const TeachingTitle: React.FC<{
  children: React.ReactNode;
  style?: React.CSSProperties;
}> = ({children, style}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  return (
    <Interactive.Div name="Headline" style={{fontWeight: 600, lineHeight: 1.04, letterSpacing: '-0.055em', whiteSpace: 'pre-line', opacity: interpolate(frame, [0, 0.5 * fps], [0, 1], {extrapolateRight: 'clamp'}), translate: `0px ${interpolate(frame, [0, 0.6 * fps], [28, 0], {extrapolateRight: 'clamp'})}px`, ...style}}>
      {children}
    </Interactive.Div>
  );
};
