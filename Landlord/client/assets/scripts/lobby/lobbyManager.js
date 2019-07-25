var lobbyManager = {}
lobbyManager.init = function(){
    this.rankListInfo = {};
}
lobbyManager.onDestroy = function(){
    this.rankListInfo = {};
},

module.exports = lobbyManager;