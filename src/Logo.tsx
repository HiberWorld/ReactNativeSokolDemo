import React from 'react';
import styled from 'styled-components/native';

const Logo = styled.View`
  border-color: blue;
  border-left-color: transparent;
  border-right-color: transparent;
  height: 0px;
  width: 0px;
  border-left-width: 50px;
  border-right-width: 50px;
  border-bottom-width: 90px;
`;

const LogoContainer = styled.View`
  width: 100%;
  padding: 32px;
  justify-content: center;
  align-items: center;
`;

export default () => (
  <LogoContainer>
    <Logo />
  </LogoContainer>
);
