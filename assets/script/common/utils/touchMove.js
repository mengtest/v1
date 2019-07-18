/*
 * @Author: Michael Zhang
 * @Date: 2019-07-18 13:42:00
 * @LastEditTime: 2019-07-18 14:02:21
 */

cc.Class({
    extends: cc.Component,

    properties: {
        target: cc.Node,
    },

    onLoad() {
        //缓存原始父节点
        this._oldPosition = this.node.position;
       
        this.node.on(cc.Node.EventType.TOUCH_MOVE, this._onTouchMove, this);
        this.node.on(cc.Node.EventType.TOUCH_END, this._onTouchEnd, this);
    },

    _onTouchMove(touchEvent) {
        let location = touchEvent.getLocation();
        this.node.position = this.node.parent.convertToNodeSpaceAR(location);
    },

    _onTouchEnd(touchEvent) {
        if (!this.target) {
            return;
        }
        //获取target节点在父容器的包围盒，返回一个矩形对象
        let rect = this.target.getBoundingBox();

        //使用target容器转换触摸坐标
        let location = touchEvent.getLocation(); // 该坐标是相对于界面左下角而讲的
        
        let point = this.target.parent.convertToNodeSpaceAR(location); // 该左边是相对于锚点讲的

        //if (cc.rectContainsPoint(rect, targetPoint)) {
        //Creator2.0使用rect的成员contains方法
        if (rect.contains(point)) {
            //在目标矩形内，修改节点坐标  
            point = this.target.convertToNodeSpaceAR(location); 
            this.node.position = point;
            //修改父节点 
            this.node.parent = this.target;
            return;
        }
        //不在矩形中，还原节点位置    
        this.node.position = this._oldPosition;
    }
});