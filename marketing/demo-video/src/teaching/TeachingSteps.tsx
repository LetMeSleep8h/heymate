import React from 'react';
import {Interactive, interpolate, useCurrentFrame, useVideoConfig} from 'remotion';
import {TEACHING, TeachingFrame, TeachingTitle} from './TeachingFrame';

const Step: React.FC<{number: string; title: string; detail: string; active: boolean}> = ({number, title, detail, active}) => (
  <div style={{borderTop: '1px solid #484D55', padding: '30px 0', display: 'flex', gap: 26, alignItems: 'flex-start', opacity: active ? 1 : 0.4}}>
    <div style={{color: active ? TEACHING.mint : TEACHING.paper, fontSize: 34, paddingTop: 8, width: 54, flexShrink: 0}}>{number}</div>
    <div>
      <div style={{fontSize: 51, lineHeight: 1.12, fontWeight: 600, letterSpacing: '-0.03em'}}>{title}</div>
      <div style={{fontSize: 35, lineHeight: 1.3, marginTop: 12, color: '#C6CBD3'}}>{detail}</div>
    </div>
  </div>
);

export const TeachingSteps: React.FC = () => {
  const frame = useCurrentFrame();
  const {width, height, fps} = useVideoConfig();
  const vertical = height > width;
  const active = Math.min(2, Math.floor(frame / (2.5 * fps)));
  return (
    <TeachingFrame dark>
      <div style={{position: 'absolute', left: 88, right: vertical ? 88 : 1030, top: vertical ? 310 : 290}}>
        <TeachingTitle style={{fontSize: vertical ? 112 : 104}}>One step.{'\n'}Your turn.</TeachingTitle>
        <div style={{marginTop: 42, fontSize: 45, lineHeight: 1.35, color: '#C6CBD3'}}>Hear it. Find it. Try it.</div>
      </div>
      <Interactive.Div name="Teaching loop" style={{position: 'absolute', left: vertical ? 88 : 1000, right: 88, top: vertical ? 820 : 255, opacity: interpolate(frame, [0.3 * fps, 0.8 * fps], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'})}}>
        <Step number="01" title="Ask for a walkthrough" detail="A plan for the task in front of you." active={active === 0} />
        <Step number="02" title="Follow the pointer" detail="You do the step in your app." active={active === 1} />
        <Step number="03" title="Continue when ready" detail="A fresh screen check. The next step." active={active === 2} />
      </Interactive.Div>
    </TeachingFrame>
  );
};
