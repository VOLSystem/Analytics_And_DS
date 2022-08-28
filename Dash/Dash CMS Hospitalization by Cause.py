from dash import Dash, dcc, html
import dash_bootstrap_components as dbc
import plotly.express as px
import pandas as pd

# input data for use
url = "https://data.cdc.gov/api/views/iw6q-r3ja/rows.csv"
df = pd.read_csv(url)

# slice dataframe to only include needed columns and categorize appropriate columns
df_agg = df[(df['LocationAbbr'] == 'US') & (df['Break_Out_Category'] == 'Overall') &
            (~df['Indicator'].str.contains('85'))]
df_agg = df_agg[['Year', 'LocationAbbr', 'LocationDesc', 'Topic', 'Data_Value',
                 'Break_Out_Category']].sort_values(by=['Year', 'Data_Value']).drop_duplicates(['Year','Topic'], keep='last')
topic_names = df_agg.Topic
# df_agg['Topic'] = pd.Categorical(df_agg.Topic)

# setup
app = Dash(__name__, external_stylesheets=[dbc.themes.SOLAR])

# animated scatter plot
fig = px.scatter(df_agg, x='Year', y='Data_Value', animation_frame='Year', size=df_agg.Data_Value*20,
           color=topic_names, hover_name=df_agg.Topic, range_x=[2003, 2014])
fig.update_layout(yaxis_title='Percentage of Admissions')

fig.layout.updatemenus[0].buttons[0].args[1]['frame']['duration'] = 800
fig.layout.updatemenus[0].buttons[0].args[1]['transition']['duration'] = 800

# static line plot
fig2 = px.line(df_agg, x='Year', y='Data_Value', color='Topic',
               hover_name='Topic', range_x=[2003, 2014])
fig2.update_layout(yaxis_title='Percentage of Admissions')

# layout
app.layout = dbc.Container([
    dbc.Row([
        dbc.Col([
            html.H1("Leading Causes of Hospitalization, Medicare(Percentage)",style={'textAlign': 'center'})
            ], width=12),
        dbc.Col([
            dcc.Graph(id='our-plot', figure=fig)
            ], width=12),
        dbc.Col([
            dcc.Graph(id='our-plot2', figure=fig2)
            ], width=12)
        ])
    ])

# run app
if __name__ == '__main__':
    app.run_server(debug=True, port=8054)
