<!doctype html>
<html lang="es">
    <head>
        <title>Consorcio Piola</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <link rel="stylesheet" type="text/css" href="app/app.css">
        <link rel="stylesheet" type="text/css" href="lib/bootstrap-4.0.0-beta.2/css/bootstrap.min.css">
        <link rel="stylesheet" type="text/css" href="skins/default.css">


    </head>
    <body>

        <h1>Consorcio Piola</h1>
        <div id="app">

            <div v-cloak preloader smooth-appear class="container-fluid" style="background-color: lightblue">
                <h1>LOADING...</h1>
            </div>

            <div v-cloak smooth-appear>

                <ul class="nav nav-tabs justify-content-end">
                    <li class="nav-item">
                        <a class="nav-link router-load-view" href="#/depositos">Depósitos</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link router-load-view" href="#/gastos">Gastos</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link router-load-view" href="#/saldos">Saldos</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link router-load-view" href="#/proveedores">Proveedores</a>
                    </li>
                </ul>

                <div class="container-fluid router-view" style="background-color: lightblue">
                    <p>{{ active_tab }}</p>
                </div>
                <div class="container">
                <div class="row">
                    <div class="col-2">
                    1 of 2
                    </div>
                    <div class="col">
                    2 of 2
                    </div>
                </div>
                <div class="row">
                    <div class="col-1">
                    1 of 3
                    </div>
                    <div class="col">
                    2 of 3
                    </div>
                    <div class="col-1">
                    3 of 3
                    </div>
                </div>
                </div>
            </div>

        </div>
    </body>



    <script src="lib/jquery-3.2.1/jquery-3.2.1.min.js"></script>
    <script src="lib/popper/popper.min.js"></script>
    <script src="lib/bootstrap-4.0.0-beta.2/js/bootstrap.min.js"></script>
    <script src="lib/vue-2.5.9/vue.js"></script>
    <script src="lib/neeko-router/neeko-router.js"></script>
    <script src="app/app.js"></script>

</html>
