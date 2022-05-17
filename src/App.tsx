import React, {useState} from 'react';
import {StatusBar} from 'react-native';
import {FullPage, PageTitle, DarkSafeArea} from './App.styles';
import Leaderboard, {LeaderboardEntry} from './Leaderboard';
import Logo from './Logo';
import {Popup} from './Popup';
import {StartTriangle} from './StartTriangle';

const App = () => {
  const [score, setScore] = useState(0);
  const [showPopup, setShowPopup] = useState(false);
  const [leaderboardData, setLeaderboardData] = useState<LeaderboardEntry[]>(
    [],
  );

  return (
    <DarkSafeArea>
      <StatusBar barStyle={'light-content'} />
      <FullPage>
        {showPopup ? (
          <Popup
            score={score}
            onSubmit={username => {
              console.log(username, score);
              setLeaderboardData([...leaderboardData, {username, score}]);
              setShowPopup(false);
            }}
          />
        ) : (
          <>
            <Logo />
            <PageTitle>Triangle Game</PageTitle>
            <StartTriangle
              gameEndCallback={res => {
                console.log('res: ', res);
                setScore(JSON.parse(res)?.score || 0);
                setShowPopup(true);
              }}
            />
            <Leaderboard leaderboardData={leaderboardData} />
          </>
        )}
      </FullPage>
    </DarkSafeArea>
  );
};

export default App;
