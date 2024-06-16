#include "raylib.h"
#include <stdlib.h>
#include <string.h>

#define SIZE 1000

#define DEAD                                                                   \
  CLITERAL(Color) { 15, 15, 15, 255 }

#define ALIVE                                                                  \
  CLITERAL(Color) { 255, 255, 255, 255 }

#define WINDOW_TITLE "Game of life"

int screenWidth = 3000;
int screenHeight = 3000;

Texture2D texture;

static int grid[SIZE][SIZE] = {0};
static bool pauseWorld = false;
static bool resetWorld = false;

void UpdateGrid(void);
void DrawWorld(void);
void InitGrid(void);
void UpdateTextureFromGrid(void);

int main(void) {

  SetConfigFlags(FLAG_WINDOW_RESIZABLE);
  InitWindow(screenWidth, screenHeight, WINDOW_TITLE);
  SetTargetFPS(60);

  InitGrid();

  // Create an image to initialize the texture
  Image screenImage =
      GenImageColor(SIZE, SIZE, DEAD); // Initially, fill with DEAD color
  texture = LoadTextureFromImage(screenImage);
  UnloadImage(screenImage);

  while (!WindowShouldClose()) {

    if (IsKeyPressed(KEY_SPACE)) {
      pauseWorld = !pauseWorld;
    }

    if (IsKeyPressed(KEY_R)) {
      InitGrid();
    }

    UpdateGrid();

    BeginDrawing();

    ClearBackground(BLACK);
    DrawWorld();

    EndDrawing();
  }

  UnloadTexture(texture); // Unload the texture when the game ends
  CloseWindow();

  return 0;
}

void DrawWorld(void) {
  // Draw the texture
  DrawTextureEx(texture, (Vector2){0, 0}, 0.0f, 10, WHITE);
}

void UpdateGrid(void) {
  if (IsMouseButtonPressed(MOUSE_BUTTON_LEFT)) {
    Vector2 pos = GetMousePosition();
    int x = pos.x / 10;
    int y = pos.y / 10;

    grid[x][y] = !grid[x][y];
    UpdateTextureFromGrid();
  }

  if (pauseWorld) {
    return;
  }

  int nextGrid[SIZE][SIZE] = {0};
  memcpy(nextGrid, grid, sizeof(grid));

  // For each cell in grid
  for (int x = 0; x < SIZE; x++) {
    for (int y = 0; y < SIZE; y++) {
      int currCell = grid[x][y];
      int alive = 0;

      // Neighbors check
      for (int j = x - 1; j <= x + 1; j++) {
        for (int k = y - 1; k <= y + 1; k++) {
          // Validity check
          if (j >= 0 && j < SIZE && k >= 0 && k < SIZE && !(j == x && k == y)) {
            if (grid[j][k] == 1) {
              alive++;
            }
          }
        }
      }

      // Conways rules
      switch (currCell) {
      case 1:
        if (alive < 2) {
          nextGrid[x][y] = 0;
        } else if (alive == 2 || alive == 3) {
          nextGrid[x][y] = 1;
        } else if (alive > 3) {
          nextGrid[x][y] = 0;
        }
        break;
      case 0:
        if (alive == 3) {
          nextGrid[x][y] = 1;
        }
        break;
      default:
        break;
      }
    }
  }

  memcpy(grid, nextGrid, sizeof(nextGrid));
  UpdateTextureFromGrid();
  return;
}

void InitGrid(void) {
  for (int x = 0; x < SIZE; x++) {
    for (int y = 0; y < SIZE; y++) {
      grid[x][y] = GetRandomValue(0, 1);
    }
  }

  UpdateTextureFromGrid();
  return;
}

void UpdateTextureFromGrid(void) {
  Color *pixels =
      (Color *)malloc(SIZE * SIZE * sizeof(Color)); // 1D Array of pixels
  for (int x = 0; x < SIZE; x++) {
    for (int y = 0; y < SIZE; y++) {
      pixels[y * SIZE + x] = grid[x][y] ? ALIVE : DEAD;
    }
  }
  UpdateTexture(texture, pixels);
  free(pixels);
}
