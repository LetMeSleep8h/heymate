import React from 'react';
import {Series, useVideoConfig} from 'remotion';
import {TeachingHook} from './teaching/TeachingHook';
import {TeachingSteps} from './teaching/TeachingSteps';
import {TeachingMates} from './teaching/TeachingMates';
import {TeachingClose} from './teaching/TeachingClose';

// A labeled concept film. No footage or successful live task is implied.
// Replace with verified recordings only in a separate, clearly named edit.
export const TeachingFirst: React.FC = () => {
  const {fps} = useVideoConfig();
  return (
    <Series>
      <Series.Sequence name="Learn it, keep it" durationInFrames={5 * fps} premountFor={fps}><TeachingHook /></Series.Sequence>
      <Series.Sequence name="Teaching loop" durationInFrames={8 * fps} premountFor={fps}><TeachingSteps /></Series.Sequence>
      <Series.Sequence name="Familiar mates" durationInFrames={6 * fps} premountFor={fps}><TeachingMates /></Series.Sequence>
      <Series.Sequence name="Try HeyMate" durationInFrames={5 * fps} premountFor={fps}><TeachingClose /></Series.Sequence>
    </Series>
  );
};
