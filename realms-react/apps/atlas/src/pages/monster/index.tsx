import React from 'react';
import Layout from '@/components/Layout';
import { ArtBackground } from '@/components/map/ArtBackground';
import { MonstersPanel } from '@/components/panels/MonstersPanel';
import { MonsterProvider } from '@/context/MonsterContext';

export default function MonsterPage() {
  return (
    <Layout>
      <MonsterProvider>
        <MonstersPanel />
      </MonsterProvider>
      <ArtBackground background="realm" />
    </Layout>
  );
}
