# Import required libraries
import pickle
import copy
import pathlib
import dash
import math
import datetime as dt
import pandas as pd
from dash.dependencies import Input, Output, State, ClientsideFunction
import plotly.graph_objs as go
import dash_core_components as dcc
import dash_html_components as html

import dash
import dash_dangerously_set_inner_html
from dateutil.relativedelta import relativedelta
from dash.dependencies import Input, Output, State

# Multi-dropdown options

# get relative data folder
PATH = pathlib.Path(__file__).parent
DATA_PATH = PATH.joinpath("data").resolve()

app = dash.Dash(
    __name__, meta_tags=[{"name": "viewport", "content": "width=device-width"}]
)
server = app.server


# Load data
df = pd.read_csv("dummy_opioid_data.csv", header=0, low_memory=False)
df['timestamp'] = pd.to_datetime(df['timestamp'])  # converts the timestamp to date_time objects


# Create global chart template
mapbox_access_token = "pk.eyJ1IjoiamFja2x1byIsImEiOiJjajNlcnh3MzEwMHZtMzNueGw3NWw5ZXF5In0.fk8k06T96Ml9CLGgKmk81w"

layout = dict(
    autosize=True,
    automargin=True,
    margin=dict(l=30, r=30, b=20, t=40),
    hovermode="closest",
    plot_bgcolor="#F9F9F9",
    paper_bgcolor="#F9F9F9",
    legend=dict(font=dict(size=10), orientation="h"),
    title="Satellite Overview",
    mapbox=dict(
        accesstoken=mapbox_access_token,
        style="light",
        center=dict(lon=-78.05, lat=42.54),
        zoom=7,
    ),
)

# Builds the layout for the header
def build_header():
    return  html.Div(
            [
                html.Div(
                    [
                        html.H3(
                            "Opioid Overdose Map",
                            style={"margin-bottom": "0px"},
                        ),
                        html.H5(
                            "Overview", style={"margin-top": "0px"}
                        ),
                    ],
                    className="three column",
                    id="title",
                ),
            ],
            id="header",
            className="row flex-display",
            style={"margin-bottom": "25px"},
        )

# Builds the layout and components for the inputs to filter the data, as well as the overdoses/month graph and the overdose map
def build_filtering():
    return html.Div([
        html.Div(
            [
                html.H3(
                   id="select-data"
                ),
            ],
            style={"margin-top": "10px", "margin-left": "auto", "margin-right": "auto", "text-align": "center"},
            className="twelve columns"
        ),

        html.Div(
            [
                html.Div(
                    [
                        html.Div(
                            [dcc.Graph(id="selector_map")],
                            className="pretty_container",
                        ),
                        html.Div(
                            [
                                html.P(
                                    id="overdoses-text",
                                    className="control_label",
                                ),
                                html.Div(
                                    [
                                        html.P(
                                            id="latitude-text",
                                            className="control_label",
                                        ),
                                        # dcc.RangeSlider(
                                        #     id="lat_slider",
                                        #     min=-90.0,
                                        #     max=90.0,
                                        #     value=[-90.0, 90.0],
                                        #     className="dcc_control",
                                        #     marks=lat_dict,
                                        # ),
                                        dcc.Input(
                                            id="lat_min",
                                            type='number',
                                            value=-90.0,
                                            placeholder="Min Latitude",
                                            min=-90.0,
                                            max=90.0,
                                            step=5,
                                            style={"margin-left": "5px"}
                                        ),
                                        dcc.Input(
                                            id="lat_max",
                                            type='number',
                                            value=90.0,
                                            placeholder="Max Latitude",
                                            min=-90.0,
                                            max=90.0,
                                            step=5,
                                            style={"margin-left": "5px"}
                                        ),
                                        html.H5(
                                            "", style={"margin-top": "30px"}
                                        ),
                                    ],
                                    className="one-half column"
                                ),
                                html.Div(
                                    [
                                        html.P(
                                            id="longitude-text",
                                            className="control_label",
                                        ),
                                        # dcc.RangeSlider(
                                        #     id="lon_slider",
                                        #     min=-180.0,
                                        #     max=180.0,
                                        #     value=[-180.0, 180.0],
                                        #     className="dcc_control",
                                        #     marks=lon_dict,
                                        # ),
                                        dcc.Input(
                                            id="lon_min",
                                            type='number',
                                            value=-90.0,
                                            placeholder="Min Longitude",
                                            min=-90.0,
                                            max=90.0,
                                            step=5,
                                            style={"margin-left": "5px"}
                                        ),
                                        dcc.Input(
                                            id="lon_max",
                                            type='number',
                                            value=90.0,
                                            placeholder="Max Longitude",
                                            min=-90.0,
                                            max=90.0,
                                            step=5,
                                            style={"margin-left": "5px"}
                                        ),
                                    ],
                                    className="one-half column"
                                ),
                                html.H5(
                                    "", style={"margin-top": "10px"}
                                ),
                            ],
                            id="map-options",
                        ),
                    ],
                    id="left-column-1",
                    style={"flex-grow": 1},
                    className="nine columns",
                ),
                html.Div(
                            [
                                html.H3(
                                    children="Number of Overdoses"
                                    ),
                                html.Div(
                                    [
                                        html.H3(id="overdoses_text"),
                                        html.P(id="overdoses-ratio")
                                    ],
                                    # id="info-container",
                                    className="mini_container",
                                    style={"text-align": "center"},
                                ),
                                html.H3(
                                    children="Naloxone administered cases",
                                    ),
                                html.Div(
                                    [
                                        html.H3(id="naloxone_text", children="121"),
                                    ],
                                    className="mini_container",
                                    style={"text-align": "center"},
                                ),
                                
                                
                            ],

                            className="three columns"
                        ),
                html.Div(
                    [
                        html.Div(
                            [dcc.Graph(id="count_graph")],
                            id="countGraphContainer",
                        ),
                        html.Div(
                            [
                                html.P(
                                    id="yearslider-text",
                                    className="control_label",
                                ),
                                # dcc.RangeSlider(
                                #     id="year_slider",
                                #     min=1962,
                                #     max=1973,
                                #     value=[1962, 1973],
                                #     className="dcc_control",
                                #     marks=year_dict
                                # ),
                                html.Div([
                                    html.Label(
                                        dcc.DatePickerRange(
                                            id='date_picker_range',
                                            min_date_allowed=dt.datetime(1962, 9, 29),
                                            max_date_allowed=dt.datetime(1972, 12, 31),
                                            #initial_visible_month=dt.datetime(1962, 9, 29),
                                            start_date=dt.datetime(1962, 9, 29),
                                            end_date=dt.datetime(1972, 12, 31),
                                            start_date_placeholder_text='Select start date',
                                            end_date_placeholder_text='Select end date',
                                            style={"margin-top": "5px"}
                                        ),
                                    ),
                                    html.Div(id='output-container-date-picker-range')
                                ]),
                                html.H5(
                                    "", style={"margin-top": "30px", "margin-bottom": "25px"}
                                )
                            ],
                            id="cross-filter-options",
                        ),
                    ],
                    id="right-column-1",
                    style={"flex-grow": 1},
                    className="six columns",
                ),
            ],
            style={"justify-content": "space-evenly"}
        ),
    ])


# Create app layout
app.layout = html.Div(
    [
        html.Div([""], id='gc-header'),
        html.Div(
            [
                dcc.Store(id="aggregate_data"),
                html.Div(id="output-clientside"),  # empty Div to trigger javascript file for graph resizing

                build_header(),
                build_filtering(),
            ],
            id="mainContainer",
            style={"font-family": "sans-serif", "display": "flex", "flex-direction": "column", "margin": "auto", "width":"75%"},
        ),
        html.Div([""], id='gc-footer'),
        html.Div(id='none2', children=[], style={'display': 'none'}), # Placeholder element to trigger translations upon page load
    ],
)


# Helper functions
def filter_dataframe(df, start_date_dt, end_date_dt, lat_min, lat_max, lon_min, lon_max):
    """Filter the extracted overdose dataframe on multiple parameters.

    Called for every component.

    Parameters
    ----------
    df : DataFrame (note: SciPy/NumPy documentation usually refers to this as array_like)
        The DataFrame with overdose data to be filtered.

    start_date_dt : datetime object
        Starting date stored as a datetime object

    end_date_dt : datetime object
        Ending date stored as a datetime object

    lat_min : double
        Minimum value of the latitude stored as a double.
        
    lat_max : double
        Maximum value of the latitude stored as a double.
        
    lon_min : double
        Minimum value of the longitude stored as a double.
        
    lon_max : double
        Maximum value of the longitude stored as a double.

    Returns
    -------
    DataFrame
        The filtered DataFrame
    """

    dff = df 
        # df[
        # (df["timestamp"].dt.date >= dt.date(start_date_dt.year, start_date_dt.month, start_date_dt.day))
        # & (df["timestamp"].dt.date <= dt.date(end_date_dt.year, end_date_dt.month, end_date_dt.day))
        #     ]
    # if (lat_min != -90) or (lat_max != 90):
    #     dff = dff[
    #         (dff["lat"] >= lat_min)
    #         & (dff["lat"] <= lat_max)
    #            ]
    # if (lon_min != -90) or (lon_max != 90):
    #     dff = dff[
    #         (dff["lon"] >= lon_min)
    #         & (dff["lon"] <= lon_max)
    #             ]

    return dff


# Selectors -> overdose count
@app.callback(
    Output("overdoses_text", "children"),
    [
        Input("date_picker_range", "start_date"),
        Input("date_picker_range", "end_date"),
        Input("lat_min", "value"),
        Input("lat_max", "value"),
        Input("lon_min", "value"),
        Input("lon_max", "value"),
    ],
)
def update_overdoses_text(start_date, end_date, lat_min, lat_max, lon_min, lon_max):
    """Update the component that counts the number of overdoses selected.

    Parameters
    ----------
    start_date : str
        Starting date stored as a str

    end_date : str
        Ending date stored as a str

    lat_min : double
        Minimum value of the latitude stored as a double.
        
    lat_max : double
        Maximum value of the latitude stored as a double.
        
    lon_min : double
        Minimum value of the longitude stored as a double.
        
    lon_max : double
        Maximum value of the longitude stored as a double.

    Returns
    -------
    int
        The number of overdoses present in the dataframe after filtering
    """
    start_time = dt.datetime.now()

    start_date = dt.datetime.strptime(start_date.split('T')[0], '%Y-%m-%d')  # Convert strings to datetime objects
    end_date = dt.datetime.strptime(end_date.split('T')[0], '%Y-%m-%d')

    dff = filter_dataframe(df, start_date, end_date, lat_min, lat_max, lon_min, lon_max)

    print('update_overdoses_text:', (dt.datetime.now()-start_time).total_seconds())

    return "{:n}".format(dff.shape[0]) + " / " + "{:n}".format(406566)


# Selectors -> count graph
@app.callback(
    Output("count_graph", "figure"),
    # [Input("visualize-button", "n_clicks")],
    [
        Input("date_picker_range", "start_date"),
        Input("date_picker_range", "end_date"),
        Input("lat_min", "value"),
        Input("lat_max", "value"),
        Input("lon_min", "value"),
        Input("lon_max", "value"),
    ],
)
def make_count_figure(start_date, end_date, lat_min, lat_max, lon_min, lon_max):
    """Create and update the histogram of selected iongograms over the given time range.

    Parameters
    ----------
    start_date : str
        Starting date stored as a str

    end_date : str
        Ending date stored as a str

    lat_min : double
        Minimum value of the latitude stored as a double.
        
    lat_max : double
        Maximum value of the latitude stored as a double.
        
    lon_min : double
        Minimum value of the longitude stored as a double.
        
    lon_max : double
        Maximum value of the longitude stored as a double.

    Returns
    -------
    dict
        A dictionary containing 2 key-value pairs: the selected data as an array of dictionaries and the histogram's
        layout as as a Plotly layout graph object.
    """
    start_time = dt.datetime.now()

    start_date = dt.datetime.strptime(start_date.split('T')[0], '%Y-%m-%d')  # Convert strings to datetime objects
    end_date = dt.datetime.strptime(end_date.split('T')[0], '%Y-%m-%d')

    layout_count = copy.deepcopy(layout)

    dff = filter_dataframe(df, start_date, end_date, lat_min, lat_max, lon_min, lon_max)
    g = dff[["id", "timestamp"]]
    g.index = g["timestamp"]
    g = g.resample("M").count()

    data = [
        dict(
            type="scatter",
            mode="markers",
            x=g.index,
            y=g['id'] / 2,
            name="All overdoses",
            opacity=0,
            hoverinfo="skip",
        ),
        dict(
            type="bar",
            x=g.index,
            y=g['id'],
            name="All overdoses",
            marker=dict(color="rgb(18, 99, 168)"),
        ),
    ]

    layout_count["title"] = "Overdoses Per Month"
    layout_count["xaxis"] = {"title": "Date", "automargin": True}
    layout_count["yaxis"] = {"title": "Number of Overdoses", "automargin": True}
    layout_count["dragmode"] = "select"
    layout_count["showlegend"] = False
    layout_count["autosize"] = True
    layout_count["transition"] = {'duration': 500}

    figure = dict(data=data, layout=layout_count)

    print('make_count_figure:', (dt.datetime.now()-start_time).total_seconds())

    return figure


@app.callback(
    Output("selector_map", "figure"),
    # [Input("visualize-button", "n_clicks")],
    [
        Input("date_picker_range", "start_date"),
        Input("date_picker_range", "end_date"),
        Input("lat_min", "value"),
        Input("lat_max", "value"),
        Input("lon_min", "value"),
        Input("lon_max", "value"),
    ],
)
def generate_geo_map(start_date, end_date, lat_min, lat_max, lon_min, lon_max):
    """Create and update the map of selected overdoses.

    Parameters
    ----------
    start_date : str
        Starting date stored as a str

    end_date : str
        Ending date stored as a str

    lat_min : double
        Minimum value of the latitude stored as a double.
        
    lat_max : double
        Maximum value of the latitude stored as a double.
        
    lon_min : double
        Minimum value of the longitude stored as a double.
        
    lon_max : double
        Maximum value of the longitude stored as a double.

    Returns
    -------
    dict
        A dictionary containing 2 key-value pairs: the selected data as an array of Plotly scattermapbox graph objects
        and the map's layout as a Plotly layout graph object.
    """
    start_time = dt.datetime.now()

    start_date = dt.datetime.strptime(start_date.split('T')[0], '%Y-%m-%d')  # Convert strings to datetime objects
    end_date = dt.datetime.strptime(end_date.split('T')[0], '%Y-%m-%d')

    filtered_data = filter_dataframe(df, start_date, end_date, lat_min, lat_max, lon_min, lon_max)
    dff = filtered_data

    traces = []

    data = [ dict(
        type = 'scattermapbox',
        lon = dff['lat'],
        lat = dff['lon'],
        text = dff['timestamp'],
        mode = 'markers',
        marker = dict(
            size = 8,
            opacity = 0.8,
            color = 'orange'
        ))]

    # relayoutData is None by default, and {'autosize': True} without relayout action
    # if main_graph_layout is not None and selector is not None and "locked" in selector:
    #     if "mapbox.center" in main_graph_layout.keys():
    #         lon = float(main_graph_layout["mapbox.center"]["lon"])
    #         lat = float(main_graph_layout["mapbox.center"]["lat"])
    #         zoom = float(main_graph_layout["mapbox.zoom"])
    #         layout["mapbox"]["center"]["lon"] = lon
    #         layout["mapbox"]["center"]["lat"] = lat
    #         layout["mapbox"]["zoom"] = zoom

    print('generate_geo_map:', (dt.datetime.now()-start_time).total_seconds())

    figure = dict(data=data, layout=layout)
    return figure
   


# Main
if __name__ == '__main__':
    app.run_server(debug=True)  # For development/testing
    # app.run_server(debug=False, host='0.0.0.0', port=8888)  # For the server
