import { Box, Button, Grid, Stack } from "@mui/joy";
import { useEffect, useState } from "react";
import { useGameContract } from "../hooks/useGameContract";
import { useTokenContract } from "../hooks/useTokenContract";

const ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");

export const GameBoard = () => {
  // States
  const [guess, setGuess] = useState<string>("");

  // Hooks
  const { handleApproveTokens, handleCheckAllowance, hasWaitedForAllowance, allowance } = useTokenContract();
  const { handleSubmitGuess, hasWaitedForGuess, isGuessCorrect } = useGameContract({ guess });

  // Game Logic
  const handleLetterClick = (letter: string) => {
    if (guess.length < 5) setGuess(prev => prev + letter);
  };

  const handleDelete = () => {
    if (guess.length > 0) setGuess(prev => prev.slice(0, -1));
  };

  // Use Effects
  useEffect(() => {
    if (hasWaitedForAllowance) {
      console.log("Allowance:", allowance.data);
    }
  }, [hasWaitedForAllowance]);

  useEffect(() => {
    if (hasWaitedForGuess) {
      console.log("Was the guess correct?: " + isGuessCorrect.data);
      setGuess("");
    }
  }, [hasWaitedForGuess]);

  useEffect(() => {
    if (hasWaitedForGuess) {
      console.log("Has waited?: " + hasWaitedForGuess);
      console.log("The guess was: " + guess);
      console.log("Was it correct?: " + hasWaitedForGuess);
    }
  }, [hasWaitedForGuess]);

  return (
    <Box sx={{ display: "flex", flexDirection: "column", gap: 2 }}>
      {/* Submit Approve Tokens Button */}
      <Stack sx={{ flexDirection: "row", gap: 1 }}>
        <Button size="lg" fullWidth onClick={handleApproveTokens} color="success">
          Approve Tokens
        </Button>
        <Button size="lg" fullWidth onClick={handleCheckAllowance} color="neutral">
          Check Allowance
        </Button>
      </Stack>

      {/* Word */}
      <Grid container sx={{ justifyContent: "space-between" }}>
        {Array.from({ length: 5 }).map((_, index) => (
          <Grid
            component={Stack}
            key={index}
            sx={{
              justifyContent: "center",
              alignItems: "center",
              border: "1px solid",
              height: { xs: 65, sm: 75 },
              width: { xs: 65, sm: 75 },
              fontSize: 32,
              fontWeight: "bold"
            }}
          >
            {guess[index]}
          </Grid>
        ))}
      </Grid>

      {/* Letters + Delete Button + Submit Guess Button */}
      <Grid container spacing={0.5} columns={6} sx={{ justifyContent: "center" }}>
        {ALPHABET.map(letter => (
          <Grid xs={1} key={letter}>
            <Button size="lg" fullWidth onClick={() => handleLetterClick(letter)} color="neutral">
              {letter}
            </Button>
          </Grid>
        ))}
        <Grid xs={2}>
          <Button size="lg" fullWidth onClick={handleDelete} color="neutral">
            Delete
          </Button>
        </Grid>
        <Grid xs={2}>
          <Button size="lg" fullWidth onClick={handleSubmitGuess} disabled={guess.length < 5} color="success">
            Submit
          </Button>
        </Grid>
      </Grid>
    </Box>
  );
};
