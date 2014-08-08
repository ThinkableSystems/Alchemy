# Alchemy.js is a graph drawing application for the web.
# Copyright (C) 2014  GraphAlchemist, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

alchemy.drawing.drawingUtils = 
    edgeUtils: () ->
        nodes = alchemy._nodes
        edges = alchemy._edges
        clustering = alchemy.layout._clustering
        # edge styles based on clustering
        if alchemy.conf.cluster
            edgeStyle = (d) ->
                clusterKey = alchemy.conf.clusterKey
                if nodes[d.source.id].properties.root or nodes[d.target.id].properties.root
                    index = (if nodes[d.source.id].properties.root then nodes[d.target.id].properties[clusterKey] else nodes[d.source.id].properties[clusterKey])
                    "#{clustering.getClusterColour(index)}"
                else if nodes[d.source.id].properties[clusterKey] is nodes[d.target.id].properties[clusterKey]
                    index = nodes[d.source.id].properties[clusterKey]
                    "#{clustering.getClusterColour(index)}"
                else if nodes[d.source.id].properties[clusterKey] isnt nodes[d.target.id].properties[clusterKey]
                    # use gradient between the two clusters' colours
                    id = "#{nodes[d.source.id].properties[clusterKey]}-#{nodes[d.target.id].properties[clusterKey]}"
                    gid = "cluster-gradient-#{id}"
                    "url(##{gid})"

        else if alchemy.conf.edgeStyle and not alchemy.conf.cluster
            edgeStyle = (d) ->
                "#{alchemy.conf.edgeStyle(d)}"
        else
            edgeStyle = (d) -> 
                ""

        square = (n) -> n * n
        hyp = (edge) ->
            # build a right triangle
            width  = edge.target.x - edge.source.x
            height = edge.target.y - edge.source.y
            # as in hypotenuse
            Math.sqrt(height * height + width * width)
        edgeWalk = (edge, point) ->
            # build a right triangle
            width  = edge.target.x - edge.source.x
            height = edge.target.y - edge.source.y
            # as in hypotenuse 
            hyp = Math.sqrt(height * height + width * width)
            distance = (hyp / 2) if point is "middle"
            return {
                x: edge.source.x + width * distance / hyp
                y: edge.source.y + height * distance / hyp
            }
        edgeAngle = (edge) ->
            width  = edge.target.x - edge.source.x
            height = edge.target.y - edge.source.y
            Math.atan2(height, width) / Math.PI * 180
        
        _middlePath = (edge) ->
            pathNode = d3.select("#path-#{edge.id}").node()
            midPoint = pathNode.getPointAtLength(pathNode.getTotalLength()/2)
                
            x: midPoint.x
            y: midPoint.y

        caption = alchemy.conf.edgeCaption
        if typeof caption is ('string' or 'number')
            edgeCaption = (d) -> edges[d.id][caption]
        else if typeof caption is 'function'
            edgeCaption = (d) -> caption(edges[d.id])


        middleLine: (edge) -> edgeWalk(edge, 'middle')
        middlePath: (edge) -> 
            # edgeWalk places text as if the line were straight
            # offset the text to lie on the mid point of the path 
        edgeLength: (edge) ->
            # build a right triangle
            width  = edge.target.x - edge.source.x
            height = edge.target.y - edge.source.y
            # as in hypotenuse 
            hyp = Math.sqrt(height * height + width * width)
        edgeAngle: (edge) -> edgeAngle(edge)
        edgeStyle: (d) -> edgeStyle(d)
        captionAngle: (edge) -> 
            angle = edgeAngle(edge)
            if angle < -90 or angle > 90
                angle += 180
            else
                angle
        edgeCaption: (d) -> edgeCaption(d)
        hyp: (edge) -> hyp(edge)
        middlePath: (edge) -> _middlePath(edge)

    nodeUtils: () ->
        nodes = alchemy._nodes
        conf = alchemy.conf
        nodeColours: (d) ->
            node_data = nodes[d.id].getProperties()
            if conf.cluster
                clusterMap = alchemy.layout._clustering.clusterMap
                clusterKey = alchemy.conf.clusterKey

                colour = conf.clusterColours[clusterMap[node_data[clusterKey]]]
                console.log colour
                "#{colour}"
            else
                if conf.nodeColour
                    colour = conf.nodeColour
                else
                    ''
        nodeStyle: (d, radius) ->
            color = @nodeColours(d)
            stroke = if alchemy.getState("interactions") is "editor" then "#E82C0C" else color
            "fill: #{color}; stroke: #{color}; stroke-width: #{ radius / 3 };"
