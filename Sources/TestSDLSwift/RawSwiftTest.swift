import CSDL2
import GL
import CnanovgGL3
import Dispatch

func runRawSwiftTest() {
    DispatchQueue.main.async {
        let SCREEN_WIDTH = Int32(400)
        let SCREEN_HEIGHT = Int32(400)

        if( SDL_Init( SDL_INIT_VIDEO ) < 0 )
        {
            print( "SDL could not initialize! SDL_Error: %s\n", SDL_GetError() );
        }    
        else
        {
            SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 8)
            SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1)
            SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1)
            SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 8)
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3)
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3)
            SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, Int32(SDL_GL_CONTEXT_PROFILE_CORE.rawValue))
            SDL_GL_SetSwapInterval(1)

            //Create window
            let window = SDL_CreateWindow( "SDL Tutorial", Int32(SDL_WINDOWPOS_CENTERED_MASK), Int32(SDL_WINDOWPOS_CENTERED_MASK), SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN.rawValue | SDL_WINDOW_OPENGL.rawValue | SDL_WINDOW_ALLOW_HIGHDPI.rawValue );
            if window == nil
            {
                print( "Window could not be created! SDL_Error: %s\n", String(cString: SDL_GetError()) );
            }
            else
            {
                //Get window surface
                /*  screenSurface = SDL_GetWindowSurface( window );

                //Fill the surface white
                SDL_FillRect( screenSurface, NULL, SDL_MapRGB( screenSurface->format, 0xFF, 0xFF, 0xFF ) );
                
                //Update the surface
                SDL_UpdateWindowSurface( window );*/

                //Wait two seconds
                //  SDL_Delay( 2000 );
            }

            let glContext = SDL_GL_CreateContext(window)

            let nvg = nvgCreateGL3(
            Int32(NVG_ANTIALIAS.rawValue | NVG_STENCIL_STROKES.rawValue | NVG_DEBUG.rawValue))

            print("CREATED WINDOW WITH OPENGLContext", glContext)
            
            SDL_GL_MakeCurrent(window, glContext)

          /*  GL.glViewport(0, 0, 400, 400)
            GL.glClearColor(0.2, 0.4, 0.2, 1)
            GL.glClear(GLMap.COLOR_BUFFER_BIT)*/

            SDL_GL_SwapWindow(window)

            SDL_Delay(2000)

            /*    //Main loop flag
            bool quit = false;

            //Event handler
            SDL_Event e;

            //While application is running
            while( !quit )
            {
                //Handle events on queue
                while(SDL_PollEvent(&e) != 0)
                {
                    //User requests quit
                    if (e.type == SDL_QUIT)
                    {
                        quit = true;
                    }
                }
            }*/

            //Destroy window
            SDL_DestroyWindow(window);

            //Quit SDL subsystems
            SDL_Quit();
        }
    }
    dispatchMain()
}