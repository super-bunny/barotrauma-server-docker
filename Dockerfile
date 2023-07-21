FROM steamcmd/steamcmd

# Build args
ARG UID=1000
ARG GID=1000
ARG USER=barotrauma

ARG STEAM_BETA
ENV STEAM_APP_ID=1026340

# Directories
ENV HOME="/barotrauma"
ENV CONFIG_DIR="/config"
ENV BASE_CONFIG_DIR="/config_base"
ENV SAVES_DIR="/saves"

# Update and install unicode symbols
RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests icu-devtools

# Symlink the game's steam client object into the include directory
RUN ln -s $HOME/linux64/steamclient.so /usr/lib/steamclient.so

# Setup directories
RUN mkdir -p $HOME $CONFIG_DIR $SAVES_DIR $BASE_CONFIG_DIR

# Create a dedicated user
RUN groupadd -g $GID $USER && \
    useradd -d $HOME -u $UID -g $USER $USER

# Install the barotrauma server
RUN steamcmd \
    +force_install_dir $HOME \
    +login anonymous \
    +app_update $STEAM_APP_ID $STEAM_BETA validate \
    +quit

COPY default/serversettings.xml "$HOME/serversettings.xml"

# Setup config folder
RUN mv \
        $HOME/serversettings.xml \
        $HOME/Data/clientpermissions.xml \
        $HOME/Data/permissionpresets.xml \
        $HOME/Data/karmasettings.xml \
        $BASE_CONFIG_DIR && \
    ln -s $CONFIG_DIR/serversettings.xml $HOME/serversettings.xml && \
    ln -s $CONFIG_DIR/clientpermissions.xml $HOME/Data/clientpermissions.xml && \
    ln -s $CONFIG_DIR/permissionpresets.xml $HOME/Data/permissionpresets.xml && \
    ln -s $CONFIG_DIR/karmasettings.xml $HOME/Data/karmasettings.xml

# Setup saves folder
RUN mkdir -p "$HOME/.local/share/Daedalic Entertainment GmbH" && \
    ln -s $SAVES_DIR "$HOME/.local/share/Daedalic Entertainment GmbH/Barotrauma"

# Set directories permissions
RUN chown -R $USER:$USER $HOME $CONFIG_DIR $SAVES_DIR $BASE_CONFIG_DIR

# Install scripts
COPY entry.sh /entry.sh

# Switch to our unprivileged user
WORKDIR $HOME
USER barotrauma

# Expose game port and query port
EXPOSE 27015/udp 27016/udp

VOLUME $CONFIG_DIR $SAVES_DIR

ENTRYPOINT ["bash", "/entry.sh"]